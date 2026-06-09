---
name: control-tower
description: 인생OS 콘트롤타워 - home.md 대시보드 자동 생성/갱신. 북극성 준수율·포커스 누적·데일리·에세이·활성스킬을 한 화면에. 주 1회+수시 실행.
---

# 🗼 콘트롤타워 스킬

> **인생OS 17개 스킬 중 #16** (Tier 6: 종합 운영)
> **주 1회 이상 + 수시** 실행 · W4 핵심

내 삶 전체를 한눈에 보는 대시보드 `home.md`를 자동 생성/갱신합니다. 흩어진 데이터(데일리·포커스 타이머·에세이·주간/월간 리포트)를 모아 **3대 지표 + 빠른 실행 + 최근 활동 + 다음 사이클 목표**로 요약합니다.

> 💡 콘트롤타워 = (1) 데이터 통합 (2) 패턴 인식 (3) 다음 사이클 기획

---

## 사용 방법

```
/control-tower
```

→ 다음을 자동 수행:
1. 볼트 루트에 `home.md` 생성 (없으면) 또는 대시보드 섹션 갱신 (있으면)
2. 데일리 노트 수 · 포커스 타이머 누적 · 에세이 수 · 활성 스킬 수 집계
3. 최근 주간/월간 리포트에서 **북극성 준수율** 가져오기
4. 최근 데일리/주간/에세이 링크 자동 연결
5. `## 🎯 다음 사이클 목표` (수동 작성 영역)은 **보존**
6. Obsidian에서 `home.md` 열기

> Obsidian 설정 → "시작 시 열 노트"를 `home.md`로 지정하면 매번 콘트롤타워로 시작합니다.

---

## 실행 로직

```bash
#!/bin/bash

# 볼트 자동 탐색 (환경변수 LIFEOS_VAULT 우선)
if [ -n "$LIFEOS_VAULT" ] && [ -d "$LIFEOS_VAULT" ]; then
    VAULT="$LIFEOS_VAULT"
else
    VAULT_LIST=$(find "$HOME" -maxdepth 1 -type d -name "lifeOS_*" 2>/dev/null)
    if [ -z "$VAULT_LIST" ]; then
        echo "❌ 인생OS 볼트를 찾을 수 없습니다. 먼저 /lifeOS-init 을 실행하세요."
        exit 1
    fi
    VAULT=$(echo "$VAULT_LIST" | head -1)
fi

USER_NAME=$(basename "$VAULT" | sed 's/lifeOS_//')
NOW=$(date "+%Y-%m-%d %H:%M")
HOME_FILE="$VAULT/home.md"

# 폴더 자동 탐색 (영문/한글)
DAILY_DIR=$(find "$VAULT" -maxdepth 1 -type d \( -name "01_daily" -o -name "01_데일리" \) | head -1)
[ -z "$DAILY_DIR" ] && DAILY_DIR="$VAULT/01_daily"

# 에세이/연대기 폴더 (08_chronicle 우선, 없으면 essays)
ESSAY_DIR=$(find "$VAULT" -maxdepth 2 -type d \( -name "08_chronicle" -o -name "08_연대기" -o -name "essays" \) 2>/dev/null | head -1)

echo "🗼 ${USER_NAME}님의 콘트롤타워 갱신 중... ($NOW)"

# ── 지표 집계 ──────────────────────────────────────────
# 1) 데일리 작성 수 (YYYY-MM-DD.md 패턴만)
DAILY_COUNT=$(find "$DAILY_DIR" -maxdepth 1 -name "20*-*-*.md" 2>/dev/null | wc -l | tr -d ' ')

# 2) 포커스 타이머 누적 (모든 focus_timer_*.csv 합산)
FOCUS_SESSIONS=0; FOCUS_MIN=0
for csv in "$DAILY_DIR"/focus_timer_*.csv; do
    [ -f "$csv" ] || continue
    rows=$(($(wc -l < "$csv") - 1)); [ $rows -lt 0 ] && rows=0
    FOCUS_SESSIONS=$((FOCUS_SESSIONS + rows))
    # duration 컬럼 자동 감지 (헤더에 duration/Duration 포함된 컬럼)
    mins=$(awk -F, 'NR==1{for(i=1;i<=NF;i++) if(tolower($i)~/duration|분/) c=i; next} {s+=$c} END{print s+0}' "$csv" 2>/dev/null)
    FOCUS_MIN=$((FOCUS_MIN + ${mins:-0}))
done

# 3) 에세이 수
ESSAY_COUNT=0
[ -n "$ESSAY_DIR" ] && ESSAY_COUNT=$(find "$ESSAY_DIR" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

# 4) 인생OS 스킬 수 (전체 스킬 중 인생OS 세트만 집계)
LIFEOS_SKILLS="today close-day focus-timer lifeOS-init north-star-define vault-setup weekly-review monthly-archive essay-publish agent-setup control-tower decision-log blocker-unblock pola-briefing delegate decision-check gallery-organize team-standup"
SKILL_COUNT=0
for s in $LIFEOS_SKILLS; do
    [ -f "$HOME/.claude/skills/$s/SKILL.md" ] && SKILL_COUNT=$((SKILL_COUNT+1))
done

# 5) 북극성 준수율 — 최근 주간 리포트에서 추출 (없으면 —)
NS_RATE="—"
WEEKLY_DIR=$(find "$VAULT" -maxdepth 2 -type d \( -name "weekly" -o -name "07_weekly" -o -name "주간" \) 2>/dev/null | head -1)
LATEST_WEEKLY=$(find "$VAULT" -name "weekly_*.md" -o -name "주간_*.md" 2>/dev/null | sort | tail -1)
if [ -n "$LATEST_WEEKLY" ]; then
    R=$(grep -oE "북극성[^0-9]*([0-9]{1,3})%" "$LATEST_WEEKLY" 2>/dev/null | grep -oE "[0-9]{1,3}%" | head -1)
    [ -n "$R" ] && NS_RATE="$R"
fi

# 6) 최근 7일 미완료
RECENT_TODOS=$(find "$DAILY_DIR" -name "20*-*-*.md" -newermt "7 days ago" 2>/dev/null \
    | xargs grep -h "^- \[ \]" 2>/dev/null | head -5)
[ -z "$RECENT_TODOS" ] && RECENT_TODOS="- (미완료 항목 없음)"

# 7) 최근 데일리 5개 링크
RECENT_DAILY=$(find "$DAILY_DIR" -maxdepth 1 -name "20*-*-*.md" 2>/dev/null \
    | sort | tail -5 | while read f; do b=$(basename "$f" .md); echo "- [[$b]]"; done)
RECENT_DAILY=$(echo "$RECENT_DAILY" | tac 2>/dev/null || echo "$RECENT_DAILY")
[ -z "$RECENT_DAILY" ] && RECENT_DAILY="- (아직 데일리 노트가 없습니다 — /today 실행)"

# 8) 최근 주간/월간 리포트
RECENT_REPORTS=$(find "$VAULT" \( -name "weekly_*.md" -o -name "주간_*.md" -o -name "monthly_*.md" -o -name "월간_*.md" \) 2>/dev/null \
    | sort | tail -3 | while read f; do b=$(basename "$f" .md); echo "- [[$b]]"; done)
[ -z "$RECENT_REPORTS" ] && RECENT_REPORTS="- (아직 없음 — /weekly-review · /monthly-archive)"

# 9) 최근 에세이 3개
RECENT_ESSAY="- (아직 없음 — /close-day · /essay-publish)"
if [ -n "$ESSAY_DIR" ]; then
    E=$(find "$ESSAY_DIR" -name "*.md" 2>/dev/null | sort | tail -3 | while read f; do b=$(basename "$f" .md); echo "- [[$b]]"; done)
    [ -n "$E" ] && RECENT_ESSAY="$E"
fi

# ── 다음 사이클 목표 (수동 영역) 보존 ──────────────────
GOAL_SECTION="## 🎯 다음 사이클 목표

- (이번 사이클에 자동화하거나 개선할 1~3가지를 직접 적으세요)
"
if [ -f "$HOME_FILE" ] && grep -q "^## 🎯 다음 사이클 목표" "$HOME_FILE"; then
    GOAL_SECTION=$(awk '/^## 🎯 다음 사이클 목표/{f=1} f&&/^## /&&!/다음 사이클 목표/{f=0} f' "$HOME_FILE")
fi

# ── home.md 작성 ──────────────────────────────────────
FOCUS_H=$((FOCUS_MIN/60)); FOCUS_M=$((FOCUS_MIN%60))
cat > "$HOME_FILE" <<EOF
# 🗼 ${USER_NAME}님의 인생OS 콘트롤타워

> 갱신: $NOW · \`/control-tower\`

## 📊 핵심 지표

| 지표 | 값 |
|------|-----|
| 🎯 북극성 준수율 | **$NS_RATE** |
| ⏱️ 포커스 누적 | **${FOCUS_SESSIONS}세션 / ${FOCUS_MIN}분** (${FOCUS_H}h ${FOCUS_M}m) |
| 📅 데일리 작성 | **${DAILY_COUNT}일** |
| ✍️ 에세이 | **${ESSAY_COUNT}편** |
| 🧩 인생OS 스킬 | **${SKILL_COUNT}개** |

## ⚡ 빠른 실행

| 언제 | 명령 |
|------|------|
| 아침 | \`/today\` |
| 수시 | \`/focus-timer start "활동"\` |
| 저녁 | \`/close-day\` |
| 일요일 | \`/weekly-review\` |
| 매달 1일 | \`/monthly-archive\` |

## ✅ 최근 7일 미완료

$RECENT_TODOS

## 📅 최근 데일리

$RECENT_DAILY

## 📈 최근 주간/월간 리포트

$RECENT_REPORTS

## ✍️ 최근 에세이

$RECENT_ESSAY

$GOAL_SECTION

---

*🗼 콘트롤타워 · /control-tower 로 언제든 갱신*
EOF

echo "✓ home.md 갱신 완료: $HOME_FILE"
echo ""
echo "📊 지표 요약:"
echo "   북극성 준수율 $NS_RATE / 포커스 ${FOCUS_SESSIONS}세션 ${FOCUS_MIN}분 / 데일리 ${DAILY_COUNT}일 / 에세이 ${ESSAY_COUNT}편 / 스킬 ${SKILL_COUNT}개"

# Obsidian 자동 열기
command -v open >/dev/null && open "$HOME_FILE" 2>/dev/null
```

---

## 📋 생성되는 home.md 예시

```markdown
# 🗼 홍길동님의 인생OS 콘트롤타워

> 갱신: 2026-06-09 22:40 · /control-tower

## 📊 핵심 지표

| 지표 | 값 |
|------|-----|
| 🎯 북극성 준수율 | **85%** |
| ⏱️ 포커스 누적 | **42세션 / 1050분** (17h 30m) |
| 📅 데일리 작성 | **28일** |
| ✍️ 에세이 | **24편** |
| 🧩 활성 스킬 | **11개** |

## ⚡ 빠른 실행
...

## 🎯 다음 사이클 목표
- 북극성 준수율 90% 목표
- 블로그 최소 주 1회 의무화
```

---

## ❓ FAQ

**Q: `home.md`를 직접 편집해도 되나요?**
A: 네. `## 🎯 다음 사이클 목표` 섹션은 수동 작성 영역으로 **보존**됩니다. 나머지 지표 섹션은 매 실행마다 새로 계산됩니다.

**Q: 북극성 준수율이 "—"로 나와요.**
A: 아직 주간 리포트가 없어서입니다. `/weekly-review`를 1회 실행하면 다음 콘트롤타워 갱신부터 자동 반영됩니다.

**Q: 얼마나 자주 실행하나요?**
A: 주 1회(일요일 주간 마감 후)가 기본이며, 수시로 현황이 궁금할 때 실행해도 됩니다.

**Q: Obsidian을 켤 때마다 콘트롤타워가 뜨게 하려면?**
A: Obsidian 설정 → "시작 시 열 노트"를 `home.md`로 지정하세요.

---

## 📌 관련 스킬

- `/today` — 아침 우선순위 (콘트롤타워의 일일 입력)
- `/weekly-review` — 주간 마감 (북극성 준수율 산출원)
- `/monthly-archive` — 월간 마감
- `/close-day` · `/essay-publish` — 에세이 누적

---

*GPTers 22기 부트캠프 W4 핵심 실습 — 콘트롤타워*
*2026-06-09 폴라 작성*
