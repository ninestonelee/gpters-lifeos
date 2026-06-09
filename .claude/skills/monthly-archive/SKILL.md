---
name: monthly-archive
description: 인생OS 월간 마감 - 지난달 데일리 노트를 월별 폴더로 정리 + 월간 리포트(작성일수·집중시간·북극성·핵심성과) 자동 생성. 매달 1일 실행.
---

# 🗓️ 월간 마감 스킬

> **인생OS 17개 스킬 중 #14** (Tier 5: 기억 보존)
> **매달 1일** 1회 실행

지난달 데일리 노트 30개를 월별 폴더로 아카이빙하고, 한 달의 흐름을 **월간 리포트**(작성일수·총 집중시간·북극성 추이·핵심 성과)로 정리합니다.

---

## 사용 방법

```
/monthly-archive
```

→ 다음을 자동 수행:
1. 지난달(`YYYY-MM`) 데일리 노트 탐색
2. `01_daily/YYYY-MM/` 폴더로 이동(아카이빙) — 원본 보존, 정리만
3. 월간 집계: 작성일수 · 총 집중시간 · 평균 북극성 준수율 · 주간 리포트 수
4. `09_monthly/monthly_YYYY-MM.md` 월간 리포트 생성
5. Obsidian에서 리포트 열기

---

## 실행 로직

```bash
#!/bin/bash

# 볼트 자동 탐색
if [ -n "$LIFEOS_VAULT" ] && [ -d "$LIFEOS_VAULT" ]; then
    VAULT="$LIFEOS_VAULT"
else
    VAULT=$(find "$HOME" -maxdepth 1 -type d -name "lifeOS_*" 2>/dev/null | head -1)
    [ -z "$VAULT" ] && { echo "❌ 볼트 없음 — /lifeOS-init 먼저"; exit 1; }
fi
USER_NAME=$(basename "$VAULT" | sed 's/lifeOS_//')

DAILY_DIR=$(find "$VAULT" -maxdepth 1 -type d \( -name "01_daily" -o -name "01_데일리" \) | head -1)
[ -z "$DAILY_DIR" ] && DAILY_DIR="$VAULT/01_daily"
MONTHLY_DIR="$VAULT/09_monthly"; mkdir -p "$MONTHLY_DIR"

# 대상 달 = 지난달 (인자로 YYYY-MM 지정 가능: /monthly-archive 2026-05)
TARGET="${1:-$(date -v-1m +%Y-%m 2>/dev/null || date -d "last month" +%Y-%m)}"
ARCHIVE_DIR="$DAILY_DIR/$TARGET"
REPORT="$MONTHLY_DIR/monthly_${TARGET}.md"

echo "🗓️ ${USER_NAME}님 월간 마감 — $TARGET"

# ── 1) 지난달 데일리 노트 수집 (루트의 YYYY-MM-DD.md 중 해당 월) ──
mapfile -t MONTH_FILES < <(find "$DAILY_DIR" -maxdepth 1 -name "${TARGET}-*.md" 2>/dev/null | sort)
DAY_COUNT=${#MONTH_FILES[@]}

if [ "$DAY_COUNT" -eq 0 ]; then
    echo "ℹ️ $TARGET 데일리 노트가 없습니다 (이미 아카이빙됐거나 기록 없음)."
fi

# ── 2) 집계 (이동 전에) ──
# 총 집중시간
M_SESSIONS=0; M_MIN=0; GOAL_HIT=0; GOAL_TOTAL=0
for csv in $(find "$DAILY_DIR" -name "focus_timer_${TARGET//-/}*.csv" 2>/dev/null); do
    [ -f "$csv" ] || continue
    read s m g <<< $(awk -F, '
        NR==1{for(i=1;i<=NF;i++){h=tolower($i); if(h~/duration|분/)dc=i; if(h~/goalcontribution|기여/)gc=i}; next}
        {n++; s+=$dc; if(gc&&tolower($gc)~/yes|y|1|true|예/)hit++}
        END{print n+0, s+0, hit+0}' "$csv" 2>/dev/null)
    M_SESSIONS=$((M_SESSIONS+${s:-0})); M_MIN=$((M_MIN+${m:-0})); GOAL_HIT=$((GOAL_HIT+${g:-0}))
done
[ "$M_SESSIONS" -gt 0 ] && NS_RATE=$(( GOAL_HIT*100/M_SESSIONS )) || NS_RATE=0

# 주간 리포트 수
WK_REPORTS=$(find "$VAULT" -name "weekly_${TARGET%-*}*.md" 2>/dev/null | wc -l | tr -d ' ')

# 핵심 성과 (각 데일리 "잘한 1가지" 첫 줄 수집)
WINS=$(for f in "${MONTH_FILES[@]}"; do
    d=$(basename "$f" .md)
    w=$(grep -A2 "잘한 1가지\|핵심 성과\|## 회고" "$f" 2>/dev/null | grep -m1 "^- \|^  -" | sed 's/^[- ]*//' | cut -c1-70)
    [ -n "$w" ] && echo "- **$d**: $w"
done | head -15)
[ -z "$WINS" ] && WINS="- (회고 기록 없음)"

# ── 3) 아카이빙 (월별 폴더로 이동) ──
MOVED=0
if [ "$DAY_COUNT" -gt 0 ]; then
    mkdir -p "$ARCHIVE_DIR"
    for f in "${MONTH_FILES[@]}"; do
        mv "$f" "$ARCHIVE_DIR/" 2>/dev/null && MOVED=$((MOVED+1))
    done
    # 해당 월 포커스 CSV도 함께 이동
    for csv in $(find "$DAILY_DIR" -maxdepth 1 -name "focus_timer_${TARGET//-/}*.csv" 2>/dev/null); do
        mv "$csv" "$ARCHIVE_DIR/" 2>/dev/null
    done
fi

DAY_RATE=$(( DAY_COUNT * 100 / 30 )); [ $DAY_RATE -gt 100 ] && DAY_RATE=100
M_H=$((M_MIN/60)); M_M=$((M_MIN%60))

# ── 4) 월간 리포트 작성 ──
cat > "$REPORT" <<EOF
# 🗓️ 월간 리포트 $TARGET

> 작성: $(date "+%Y-%m-%d %H:%M") · \`/monthly-archive\`

## 핵심 지표

| 지표 | 값 |
|------|-----|
| 📅 데일리 작성 | ${DAY_COUNT}일 (월 기준 ~${DAY_RATE}%) |
| ⏱️ 총 집중 | ${M_SESSIONS}세션 / ${M_MIN}분 (${M_H}h ${M_M}m) |
| 🎯 평균 북극성 준수율 | ${NS_RATE}% (목표기여 ${GOAL_HIT}/${M_SESSIONS}세션) |
| 📈 주간 리포트 | ${WK_REPORTS}개 |
| 📦 아카이빙 | ${MOVED}개 → \`01_daily/$TARGET/\` |

## 🏆 이달의 핵심 성과

$WINS

## 🔭 다음 달 회고 (직접 작성)

- 이달 가장 큰 변화:
- 다음 달 1순위 목표:
- 자동화/개선하고 싶은 1가지:

---

*🗓️ 월간 마감 · $TARGET 데일리 ${MOVED}개 아카이빙 완료*
EOF

echo "✓ 월간 리포트: $REPORT"
echo "   📅 ${DAY_COUNT}일 / 집중 ${M_MIN}분 / 북극성 ${NS_RATE}% / 아카이빙 ${MOVED}개 → 01_daily/$TARGET/"

command -v open >/dev/null && open "$REPORT" 2>/dev/null
```

---

## 📋 아카이빙 구조

```
01_daily/
├── 2026-06-09.md         ← 이번 달 (루트 유지)
├── 2026-06-08.md
├── 2026-05/              ← 지난달 아카이브 (자동 생성)
│   ├── 2026-05-01.md
│   ├── ...
│   └── focus_timer_*.csv
09_monthly/
└── monthly_2026-05.md    ← 월간 리포트
```

---

## ❓ FAQ

**Q: 노트가 사라지나요?**
A: 아니요. **이동(아카이빙)만** 합니다 — `01_daily/YYYY-MM/` 하위 폴더로 옮겨 정리할 뿐, 삭제하지 않습니다. Obsidian 링크(`[[2026-05-01]]`)도 그대로 작동합니다.

**Q: 특정 달을 정리하고 싶어요.**
A: `/monthly-archive 2026-05` 처럼 `YYYY-MM`을 인자로 주세요. 인자가 없으면 지난달을 정리합니다.

**Q: 매달 1일에 까먹으면요?**
A: 며칠 지나서 실행해도 됩니다. 지난달 기준으로 동작합니다.

---

## 📌 관련 스킬

- `/weekly-review` — 주간 마감 (월간의 입력)
- `/close-day` — 일일 마감
- `/control-tower` — 월간 리포트를 대시보드로 통합
- `/essay-publish` — 에세이 월별 정리

---

*GPTers 22기 부트캠프 W4 핵심 실습 — 월간 마감*
*2026-06-09 폴라 작성*
