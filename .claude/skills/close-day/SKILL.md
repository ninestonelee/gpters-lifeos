---
name: close-day
description: 인생OS 하루 마감 - 데일리 노트 회고 + 포커스 타이머 CSV 결산 + 에세이 자동 정리. 매일 저녁 22~23시 실행.
---

# 🌙 하루 마감 스킬

> **인생OS 17개 스킬 중 #2** (Tier 1: 일일 루틴)
> **매일 저녁 22~23시** 1회 실행

오늘 데일리 노트 회고 섹션 채움 + 포커스 타이머 CSV 결산 + 에세이 1편 작성을 한 번에.

---

## 사용 방법

```
/close-day
```

→ 다음을 자동 수행:
1. 오늘 데일리 노트 (`01_daily/YYYY-MM-DD.md`) 읽기
2. 오늘 포커스 타이머 CSV → 표로 데일리 노트에 자동 삽입
3. 진행 중인 세션이 있으면 자동 종료 안내
4. 회고 섹션 가이드 표시 (3개 질문)
5. 에세이 1편 작성 (`07_scratch_ai/YYYY-MM-DD_에세이.md`)
6. 내일 데이터 준비 (어제 = 오늘이 되도록)

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
        echo "❌ 인생OS 볼트를 찾을 수 없습니다."
        echo "   먼저 /lifeOS-init 을 실행하세요."
        exit 1
    fi
    VAULT_COUNT=$(echo "$VAULT_LIST" | wc -l | tr -d ' ')
    VAULT=$(echo "$VAULT_LIST" | head -1)
    if [ "$VAULT_COUNT" -gt 1 ]; then
        echo "⚠️  여러 볼트 발견 (현재: $(basename $VAULT)):" >&2
        echo "$VAULT_LIST" | sed 's|^|     |' >&2
        echo "   특정 볼트 지정: export LIFEOS_VAULT=~/lifeOS_[name]" >&2
        echo "" >&2
    fi
fi

USER_NAME=$(basename "$VAULT" | sed 's/lifeOS_//')
TODAY=$(date +%Y-%m-%d)
TODAY_COMPACT=$(date +%Y%m%d)

# 폴더 자동 탐색
DAILY_DIR=$(find "$VAULT" -maxdepth 1 -type d \( -name "01_daily" -o -name "01_데일리" \) | head -1)
SCRATCH_DIR=$(find "$VAULT" -maxdepth 1 -type d \( -name "07_scratch_ai" -o -name "07_AI초안" \) | head -1)
[ -z "$SCRATCH_DIR" ] && SCRATCH_DIR="$VAULT/07_scratch_ai" && mkdir -p "$SCRATCH_DIR"

TODAY_FILE="$DAILY_DIR/$TODAY.md"
CSV="$DAILY_DIR/focus_timer_$TODAY_COMPACT.csv"
STATE="$DAILY_DIR/.focus_timer_state"
ESSAY="$SCRATCH_DIR/${TODAY}_에세이.md"

echo ""
echo "🌙 ${USER_NAME}님의 하루 마감 ($TODAY)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 1. 진행 중 세션 자동 종료 안내
if [ -f "$STATE" ]; then
    echo "⚠️  진행 중인 포커스 타이머 세션 발견:"
    cat "$STATE"
    echo ""
    read -p "   자동 종료할까요? (Y/n): " AUTO_STOP
    if [ "$AUTO_STOP" != "n" ]; then
        IFS='|' read -r SESSION_NO START_TIME ACTIVITY < "$STATE"
        END_TIME=$(date +%H:%M)
        START_MIN=$(( $(echo "$START_TIME" | cut -d: -f1) * 60 + $(echo "$START_TIME" | cut -d: -f2) ))
        END_MIN=$(( $(echo "$END_TIME" | cut -d: -f1) * 60 + $(echo "$END_TIME" | cut -d: -f2) ))
        DURATION=$((END_MIN - START_MIN))
        [ $DURATION -lt 0 ] && DURATION=$((DURATION + 1440))
        echo "$SESSION_NO,$START_TIME,$END_TIME,$DURATION,$ACTIVITY,(자동종료)" >> "$CSV"
        rm "$STATE"
        echo "   ✓ 세션 #$SESSION_NO 자동 종료 (${DURATION}분)"
    fi
fi

# 2. 오늘 데일리 노트 확인
if [ ! -f "$TODAY_FILE" ]; then
    echo "⚠️  오늘 데일리 노트가 없습니다."
    echo "   /today 를 먼저 실행하거나 빈 노트를 만듭니다."
    cat > "$TODAY_FILE" <<EOF
# $TODAY

## 포커스 타이머

## 회고

EOF
fi

# 3. 포커스 타이머 결산 → 데일리 노트 삽입
echo "📊 포커스 타이머 결산:"
if [ -f "$CSV" ] && [ $(wc -l < "$CSV") -gt 1 ]; then
    COUNT=$(($(wc -l < "$CSV") - 1))
    TOTAL=$(awk -F, 'NR>1 {sum+=$4} END {print sum}' "$CSV")
    echo "   ${COUNT}개 세션, ${TOTAL}분 (≈ $((TOTAL/60))h $((TOTAL%60))m)"

    # 시간대별 집계 (오전: 06-12, 오후: 12-18, 저녁: 18-24)
    AM=$(awk -F, 'NR>1 {h=substr($2,1,2)+0; if (h>=6 && h<12) {n++; m+=$4}} END {print n"|"m+0}' "$CSV")
    PM=$(awk -F, 'NR>1 {h=substr($2,1,2)+0; if (h>=12 && h<18) {n++; m+=$4}} END {print n"|"m+0}' "$CSV")
    EV=$(awk -F, 'NR>1 {h=substr($2,1,2)+0; if (h>=18 || h<6) {n++; m+=$4}} END {print n"|"m+0}' "$CSV")

    AM_N=$(echo $AM | cut -d'|' -f1); AM_M=$(echo $AM | cut -d'|' -f2)
    PM_N=$(echo $PM | cut -d'|' -f1); PM_M=$(echo $PM | cut -d'|' -f2)
    EV_N=$(echo $EV | cut -d'|' -f1); EV_M=$(echo $EV | cut -d'|' -f2)

    # 시간대별 활동 요약 (csv 컬럼 5)
    AM_ACT=$(awk -F, 'NR>1 {h=substr($2,1,2)+0; if (h>=6 && h<12) print $5}' "$CSV" | paste -sd"," - | sed 's/,$//')
    PM_ACT=$(awk -F, 'NR>1 {h=substr($2,1,2)+0; if (h>=12 && h<18) print $5}' "$CSV" | paste -sd"," - | sed 's/,$//')
    EV_ACT=$(awk -F, 'NR>1 {h=substr($2,1,2)+0; if (h>=18 || h<6) print $5}' "$CSV" | paste -sd"," - | sed 's/,$//')

    TIMER_TABLE=$(cat <<EOF
## 포커스 타이머

| 시간대 | 세션 | 분 | 활동 |
|--------|------|-----|------|
| 오전 | $AM_N | $AM_M | $AM_ACT |
| 오후 | $PM_N | $PM_M | $PM_ACT |
| 저녁 | $EV_N | $EV_M | $EV_ACT |
| **합계** | **$COUNT** | **$TOTAL** | |
EOF
)

    # 데일리 노트에 삽입 (## 포커스 타이머 섹션 교체)
    python3 - "$TODAY_FILE" <<PYEOF
import sys, re
fn = sys.argv[1]
with open(fn) as f: content = f.read()
table = """$TIMER_TABLE"""
pattern = r'## 포커스 타이머.*?(?=\n## |\Z)'
if re.search(pattern, content, re.DOTALL):
    new = re.sub(pattern, table.strip() + '\n\n', content, count=1, flags=re.DOTALL)
else:
    new = content + '\n' + table + '\n'
with open(fn, 'w') as f: f.write(new)
PYEOF
    echo "   ✓ 데일리 노트 포커스 타이머 섹션 갱신"
else
    echo "   (오늘 기록 없음)"
fi

# 4. 회고 가이드 표시
echo ""
echo "📝 회고 가이드 — 데일리 노트 ## 회고 섹션에 답하세요:"
echo "   1. 오늘 가장 잘한 1가지는?"
echo "   2. 오늘 가장 아쉬운 1가지는?"
echo "   3. 내일 더 잘하기 위해 바꿀 1가지는?"
echo ""

# 5. 에세이 작성 가이드
if [ ! -f "$ESSAY" ]; then
    cat > "$ESSAY" <<EOF
# ${TODAY} 에세이

> 오늘 깨달은 것, 만난 사람, 느낀 감정을 자유롭게 300단어 정도로.
> 폴라 톤: 하루키 + 김영하 + 이석원 (선택)

## 명장면 1개
(오늘 가장 인상 깊었던 순간 한 장면)

## 깨달음
(그 장면에서 무엇을 배웠나)

## 내일에게
(내일의 나에게 한 마디)

---

*${USER_NAME} · ${TODAY}*
EOF
    echo "📓 에세이 템플릿 생성: $ESSAY"
else
    echo "📓 에세이 파일 이미 존재: $ESSAY"
fi

# 6. 결산 요약
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 하루 마감 준비 완료"
echo ""
echo "📌 마무리 체크리스트:"
echo "   [ ] 데일리 노트 ## 회고 섹션 작성"
echo "   [ ] 에세이 작성 ($(basename $ESSAY))"
echo "   [ ] Obsidian에서 저장 확인"
echo "   [ ] 내일 /today 알람 (07:30 권장)"
echo ""

# Obsidian 자동 열기 (회고 작성용)
if command -v open &> /dev/null; then
    open "$TODAY_FILE" 2>/dev/null
fi
```

---

## 📋 데일리 노트 자동 갱신 예시

`/close-day` 실행 후 `01_daily/2026-05-26.md`:

```markdown
# 2026-05-26

## AI 브리핑 (자동 생성: 07:32)
...

## 포커스 타이머

| 시간대 | 세션 | 분 | 활동 |
|--------|------|-----|------|
| 오전 | 2 | 67 | 북극성 정의, 이메일 정리 |
| 오후 | 2 | 55 | 회의 준비, 블로그 초안 |
| 저녁 | 1 | 25 | close-day |
| **합계** | **5** | **147** | |

## 회고
(수동 입력 — 3개 질문 답변)

```

---

## ❓ FAQ

**Q: 포커스 타이머를 안 썼어요. close-day가 작동하나요?**
A: 네. "(오늘 기록 없음)"으로 표시되고 정상 진행됩니다.

**Q: 에세이가 매일 부담스러워요.**
A: 3~5개 문장도 충분합니다. **꾸준함 > 완성도**.

**Q: 회고 섹션을 비워두면 안 되나요?**
A: 가능하지만 권장하지 않습니다. 매일 5분 회고가 4주 후 가장 큰 자산이 됩니다.

**Q: 진행 중인 포커스 타이머 세션을 자동 종료하면 시간이 부정확하지 않나요?**
A: 부정확합니다. **/focus-timer stop을 직접 실행한 시간 vs close-day 실행 시간**의 차이만큼 오차 발생. close-day 전에 stop 권장.

---

## 📌 관련 스킬

- `/today` — 아침 루틴 (이 스킬과 짝)
- `/focus-timer` — 일일 세션 기록 (이 스킬이 CSV 결산)
- `/north-star-define` — 회고 기준 (북극성 행동 점검)
- `/weekly-review` — 주간 리뷰 (W3 출시 예정)

---

*GPTers 22기 부트캠프 W1 일일 루틴 #2*
*2026-05-20 폴라 작성*
