---
name: focus-timer
description: 인생OS 포커스 타이머 - 25분 집중 세션 시작/종료 + CSV 자동 기록. 하루 5개 의사결정 추적.
---

# ⏱️ 포커스 타이머 스킬

> **인생OS 17개 스킬 중 #3** (Tier 1: 일일 루틴)
> **W1부터 사용 가능** · 매일 수시 실행

하루 5개의 큰 결정을 25분 세션으로 추적하는 스킬. 의도(예상) vs 실제 시간을 기록하여 **의사결정 패턴**을 시각화합니다.

---

## 사용 방법

### 1. 세션 시작
```
/focus-timer start "북극성 정의"
```
→ 타이머 시작 시간 기록, 활동명 저장

### 2. 세션 종료
```
/focus-timer stop
```
→ 종료 시간 + 실제 소요 시간 자동 계산 → CSV에 추가

### 3. 오늘 결산 보기
```
/focus-timer log
```
→ 오늘 CSV 읽어서 표로 출력

---

## CSV 파일 형식

저장 위치: `~/lifeOS_[name]/01_daily/focus_timer_YYYYMMDD.csv`

```csv
session_no,start_time,end_time,duration_min,activity,intent
1,08:00,08:25,25,북극성 정의,오늘 시작 전 가치 3개 확정
2,10:00,10:42,42,이메일 정리,30분 예상이었으나 12분 초과
3,14:00,14:25,25,회의 준비,
4,16:00,16:30,30,블로그 초안,
5,21:00,21:25,25,close-day,
```

---

## 실행 로직 (수강생 환경 자동 감지)

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

TODAY=$(date +%Y%m%d)
TODAY_ISO=$(date +%Y-%m-%d)
CSV="$VAULT/01_daily/focus_timer_$TODAY.csv"
STATE="$VAULT/01_daily/.focus_timer_state"

# CSV 헤더 초기화 (오늘 첫 실행)
if [ ! -f "$CSV" ]; then
    echo "session_no,start_time,end_time,duration_min,activity,intent" > "$CSV"
fi

ACTION="${1:-status}"
ACTIVITY="${2:-(미입력)}"

case "$ACTION" in
  start)
    if [ -f "$STATE" ]; then
        echo "⚠️  이미 진행 중인 세션이 있습니다."
        echo "   먼저 /focus-timer stop 으로 종료하세요."
        cat "$STATE"
        exit 1
    fi
    NOW=$(date +%H:%M)
    SESSION_NO=$(($(wc -l < "$CSV") - 0))  # 헤더 제외하면 다음 번호
    echo "$SESSION_NO|$NOW|$ACTIVITY" > "$STATE"
    echo "▶️  세션 #$SESSION_NO 시작 ($NOW)"
    echo "   활동: $ACTIVITY"
    echo "   25분 후 /focus-timer stop 으로 종료하세요."
    ;;

  stop)
    if [ ! -f "$STATE" ]; then
        echo "❌ 진행 중인 세션이 없습니다."
        echo "   /focus-timer start \"활동명\" 으로 시작하세요."
        exit 1
    fi
    IFS='|' read -r SESSION_NO START_TIME ACTIVITY < "$STATE"
    END_TIME=$(date +%H:%M)
    # 분 단위 차이 계산
    START_MIN=$(( $(echo "$START_TIME" | cut -d: -f1) * 60 + $(echo "$START_TIME" | cut -d: -f2) ))
    END_MIN=$(( $(echo "$END_TIME" | cut -d: -f1) * 60 + $(echo "$END_TIME" | cut -d: -f2) ))
    DURATION=$((END_MIN - START_MIN))
    [ $DURATION -lt 0 ] && DURATION=$((DURATION + 1440))  # 자정 넘김 보정

    echo "$SESSION_NO,$START_TIME,$END_TIME,$DURATION,$ACTIVITY," >> "$CSV"
    rm "$STATE"
    echo "⏹️  세션 #$SESSION_NO 종료 ($END_TIME)"
    echo "   소요: ${DURATION}분"
    echo "   활동: $ACTIVITY"
    echo "   CSV 저장: $CSV"
    ;;

  log|status)
    if [ ! -s "$CSV" ] || [ $(wc -l < "$CSV") -le 1 ]; then
        echo "📋 오늘($TODAY_ISO) 기록된 세션이 없습니다."
        if [ -f "$STATE" ]; then
            echo ""
            echo "▶️  진행 중인 세션:"
            cat "$STATE"
        fi
        exit 0
    fi
    echo "📋 오늘($TODAY_ISO) 포커스 타이머"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    column -t -s, "$CSV"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    TOTAL=$(awk -F, 'NR>1 {sum+=$4} END {print sum}' "$CSV")
    COUNT=$(($(wc -l < "$CSV") - 1))
    echo "총 ${COUNT}개 세션, ${TOTAL}분 (${TOTAL} min ≈ $((TOTAL/60))h $((TOTAL%60))m)"
    if [ -f "$STATE" ]; then
        echo ""
        echo "▶️  진행 중: $(cat $STATE)"
    fi
    ;;

  *)
    echo "사용법:"
    echo "  /focus-timer start \"활동명\"   세션 시작"
    echo "  /focus-timer stop              세션 종료"
    echo "  /focus-timer log               오늘 결산 보기"
    ;;
esac
```

---

## 🎯 실행 가이드

### 매일 권장 흐름

```
07:30  /today              ← 오늘 우선순위 확인
08:00  /focus-timer start "북극성 점검"
08:25  /focus-timer stop
10:00  /focus-timer start "이메일 정리"
...
21:00  /focus-timer log    ← 하루 결산 미리보기
22:00  /close-day          ← 데일리 노트에 CSV 자동 반영
```

### 활동명 작성 팁

| ❌ 모호함 | ✅ 명확함 |
|---------|---------|
| "일" | "고객 미팅 자료 준비" |
| "공부" | "Claude Code 17스킬 가이드 정독" |
| "회의" | "팀 주간 회의 (마케팅 안건)" |

### 5개 결정 기준

하루 25분 세션 5개 = **하루의 핵심 결정 5개**입니다. 잡일이 아니라 **의도적으로 한 큰 결정**만 기록하세요.

---

## 📊 close-day 연동

저녁에 `/close-day` 실행하면 이 CSV가 자동으로 데일리 노트의 `## 포커스 타이머` 섹션에 표로 정리됩니다.

```markdown
| 시간대 | 세션 | 분 | 활동 |
|--------|------|----|------|
| 오전 | 2 | 67 | 북극성 정의, 이메일 정리 |
| 오후 | 2 | 55 | 회의 준비, 블로그 초안 |
| 저녁 | 1 | 25 | close-day |
| 합계 | 5 | 147 | |
```

---

## ❓ FAQ

**Q: 세션이 25분보다 길어졌어요. 어떻게 하나요?**
A: 그대로 stop하세요. 실제 시간이 자동 기록됩니다. **예상 vs 실제**의 차이가 가장 중요한 데이터입니다.

**Q: 활동을 잊고 stop을 안 했어요.**
A: 다음 날에는 state 파일이 그대로 남아있을 수 있습니다. `~/lifeOS_*/01_daily/.focus_timer_state` 파일을 수동 삭제하면 초기화됩니다.

**Q: CSV를 직접 편집해도 되나요?**
A: 네. 메모 컬럼(intent)을 나중에 채우는 것이 일반적입니다.

**Q: 5개를 못 채우면 실패인가요?**
A: 아닙니다. 1~2개라도 의도적으로 기록하면 충분합니다. **꾸준함이 핵심**입니다.

---

## 📌 관련 스킬

- `/today` — 아침 우선순위 (포커스 타이머 활동 선정에 참조)
- `/close-day` — 저녁 마감 (포커스 타이머 CSV → 데일리 노트 자동 반영)
- `/decision-log` — 의사결정 로그 (W2 출시 예정)

---

*GPTers 22기 부트캠프 W1 핵심 실습 스킬*
*2026-05-20 폴라 작성*
