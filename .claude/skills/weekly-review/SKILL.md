---
name: weekly-review
description: 인생OS 주간 마감 - 지난 7일 데일리+포커스 분석, 북극성 준수율 산출, 미완료 이월, 주간 리포트 자동 생성. 매주 일요일 저녁 실행.
---

# 📈 주간 마감 스킬

> **인생OS 17개 스킬 중 #8** (Tier 3: 의사결정 추적)
> **매주 일요일 저녁** 1회 실행

지난 7일의 데일리 노트 + 포커스 타이머를 분석해 **북극성 준수율·집중 추이·미완료 이월·주간 테마**를 한 장의 주간 리포트로 정리합니다. 이 리포트의 북극성 준수율은 `/control-tower` 대시보드로 자동 연결됩니다.

---

## 사용 방법

```
/weekly-review
```

→ 다음을 자동 수행:
1. 지난 7일 데일리 노트 + `focus_timer_*.csv` 수집
2. **북극성 준수율** 산출 (포커스 세션 중 목표기여 비율)
3. 주간 집중 총합 · 데일리 작성률 · 미완료 이월 집계
4. `07_weekly/weekly_YYYY-Www.md` 주간 리포트 생성
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
WEEKLY_DIR="$VAULT/07_weekly"; mkdir -p "$WEEKLY_DIR"

TODAY=$(date +%Y-%m-%d)
WEEK=$(date +%Y-W%V)           # ISO 주차 (예: 2026-W24)
WEEK_AGO=$(date -v-7d +%Y-%m-%d 2>/dev/null || date -d "7 days ago" +%Y-%m-%d)
REPORT="$WEEKLY_DIR/weekly_${WEEK}.md"

echo "📈 ${USER_NAME}님 주간 마감 ($WEEK_AGO ~ $TODAY)"

# ── 1) 데일리 작성률 (지난 7일) ──
DAILY_DAYS=$(find "$DAILY_DIR" -name "20*-*-*.md" -newermt "7 days ago" 2>/dev/null | wc -l | tr -d ' ')

# ── 2) 포커스 집계 + 북극성 준수율 (GoalContribution 컬럼 기반) ──
WK_SESSIONS=0; WK_MIN=0; GOAL_HIT=0
for csv in $(find "$DAILY_DIR" -name "focus_timer_*.csv" -newermt "7 days ago" 2>/dev/null); do
    [ -f "$csv" ] || continue
    # 컬럼 자동 감지: duration, GoalContribution
    read s m g <<< $(awk -F, '
        NR==1{for(i=1;i<=NF;i++){h=tolower($i); if(h~/duration|분/)dc=i; if(h~/goalcontribution|goal_contrib|기여/)gc=i}; next}
        {n++; s+=$dc; if(gc&&tolower($gc)~/yes|y|1|true|예/)hit++}
        END{print n+0, s+0, hit+0}' "$csv" 2>/dev/null)
    WK_SESSIONS=$((WK_SESSIONS + ${s:-0}))
    WK_MIN=$((WK_MIN + ${m:-0}))
    GOAL_HIT=$((GOAL_HIT + ${g:-0}))
done

if [ "$WK_SESSIONS" -gt 0 ]; then
    NS_RATE=$(( GOAL_HIT * 100 / WK_SESSIONS ))
else
    NS_RATE=0
fi
# 데일리 작성률도 보조 지표 (7 초과 시 100% 캡)
[ "$DAILY_DAYS" -gt 7 ] && DAILY_DAYS=7
DAILY_RATE=$(( DAILY_DAYS * 100 / 7 ))

# ── 3) 미완료 이월 ──
CARRY=$(find "$DAILY_DIR" -name "20*-*-*.md" -newermt "7 days ago" 2>/dev/null \
    | xargs grep -h "^- \[ \]" 2>/dev/null | sort -u | head -10)
[ -z "$CARRY" ] && CARRY="- (이월 미완료 없음 — 깔끔합니다!)"

# ── 4) 주간 회고 테마 (회고 섹션 첫 줄 모음) ──
THEMES=$(for f in $(find "$DAILY_DIR" -name "20*-*-*.md" -newermt "7 days ago" 2>/dev/null | sort); do
    d=$(basename "$f" .md)
    line=$(grep -A2 "잘한 1가지\|배운 1가지\|## 회고" "$f" 2>/dev/null | grep -m1 "^- \|^  -" | sed 's/^[- ]*//' | cut -c1-60)
    [ -n "$line" ] && echo "- **$d**: $line"
done | head -7)
[ -z "$THEMES" ] && THEMES="- (회고 기록 없음)"

WK_H=$((WK_MIN/60)); WK_M=$((WK_MIN%60))

# ── 5) 주간 리포트 작성 ──
# 평가 이모지
if [ "$NS_RATE" -ge 80 ]; then NS_EMOJI="🟢"; elif [ "$NS_RATE" -ge 50 ]; then NS_EMOJI="🟡"; else NS_EMOJI="🔴"; fi

cat > "$REPORT" <<EOF
# 📈 주간 리포트 $WEEK ($WEEK_AGO ~ $TODAY)

> 작성: $(date "+%Y-%m-%d %H:%M") · \`/weekly-review\`

## 핵심 지표

| 지표 | 값 |
|------|-----|
| 🎯 북극성 준수율 | **${NS_RATE}%** $NS_EMOJI (목표기여 ${GOAL_HIT}/${WK_SESSIONS}세션) |
| ⏱️ 주간 집중 | ${WK_SESSIONS}세션 / ${WK_MIN}분 (${WK_H}h ${WK_M}m) |
| 📅 데일리 작성률 | ${DAILY_RATE}% (${DAILY_DAYS}/7일) |

## 🔁 미완료 이월 (다음 주로)

$CARRY

## 🧭 주간 회고 테마

$THEMES

## 📝 주간 점검 (직접 작성)

- 이번 주 가장 잘한 1가지:
- 가장 아쉬운 1가지:
- 다음 주 1순위:

---

*📈 주간 마감 · 다음: 매달 1일 /monthly-archive*
EOF

echo "✓ 주간 리포트: $REPORT"
echo "   🎯 북극성 준수율 ${NS_RATE}% (목표기여 ${GOAL_HIT}/${WK_SESSIONS}) / 집중 ${WK_MIN}분 / 데일리 ${DAILY_DAYS}/7일"
echo ""
echo "💡 다음: /control-tower 로 대시보드에 반영"

command -v open >/dev/null && open "$REPORT" 2>/dev/null
```

---

## 📊 북극성 준수율 산출 방식

포커스 타이머 CSV의 `GoalContribution` 컬럼(목표 기여 여부 = yes)을 활용합니다:

```
북극성 준수율 = (목표기여 세션 수 / 전체 세션 수) × 100
```

→ 의도(북극성)에 정렬된 시간을 얼마나 보냈는지 **실측**합니다.
→ 포커스 세션 기록 시 "이 세션이 북극성에 기여했나?"를 yes/no로 남기면 정확해집니다.

---

## ❓ FAQ

**Q: 북극성 준수율이 0%로 나와요.**
A: 포커스 타이머 CSV에 `GoalContribution` 기록이 없어서입니다. `/focus-timer` 세션 종료 시 목표 기여 여부를 남기거나, 리포트의 "주간 점검"에서 직접 평가하세요.

**Q: 주차 표기(2026-W24)가 뭔가요?**
A: ISO 8601 주차입니다. 한 해의 몇 번째 주인지를 뜻하며 리포트가 시간순으로 정렬됩니다.

**Q: `/control-tower`와 어떻게 연결되나요?**
A: 주간 리포트의 "북극성 준수율 NN%" 줄을 콘트롤타워가 자동으로 읽어 대시보드에 표시합니다.

---

## 📌 관련 스킬

- `/close-day` — 일일 마감 (주간 데이터의 원천)
- `/focus-timer` — 목표기여 기록 (북극성 준수율 산출원)
- `/monthly-archive` — 월간 마감
- `/control-tower` — 주간 결과를 대시보드로 통합

---

*GPTers 22기 부트캠프 W3 핵심 실습 — 주간 마감*
*2026-06-09 폴라 작성*
