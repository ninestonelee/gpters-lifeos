---
name: north-star-define
description: 인생OS 북극성 정의 워크샵 - 가치 3개 + 행동 3개 + 주간 체크 기준을 대화형으로 작성. W1 핵심 실습.
---

# 🌟 북극성 정의 워크샵

> **인생OS 17개 스킬 중 #5** (Tier 2: 기초 설정)
> **W1 강의 중 필수 실습** · 4주간 1회 작성 후 고정

당신의 **북극성(North Star)** = 4주 동안 모든 의사결정의 판단 기준.
가치 → 구체 행동 → 측정 기준 3단계로 작성합니다.

---

## 사용 방법

```
/north-star-define
```

→ 5개 질문에 답변 → `~/lifeOS_[name]/04_concepts/북극성_[name].md` 자동 생성

---

## 워크샵 5단계

### Step 1: 가치 3개 (Why)
"내가 인생에서 가장 중요하게 여기는 가치 3개는?"

예시:
- 의도, 학습, 기여
- 자유, 깊이, 연결
- 정직, 성장, 가족

> 💡 **팁**: 명사 1~2단어. 추상적이어도 OK. 4주간 흔들리지 않을 만큼 진심인 것.

### Step 2: 구체 행동 3개 (What)
"이 가치를 매일 실행하기 위한 구체 행동 3개는?"

예시 (의도/학습/기여 → ):
- "매 결정 전에 5분 멈춘다" (의도)
- "하루 1시간 공부 시간 확보" (학습)
- "팀원 1명한테 배운 점 공유" (기여)

> 💡 **팁**: 동사로 시작. 측정 가능. 매일 또는 주 3회 이상 실행 가능한 빈도.

### Step 3: 주간 체크 기준 (How)
"이 행동을 잘 지키고 있는지 매주 확인할 기준은?"

예시:
- "5분 멈춤"을 한 결정 / 전체 큰 결정의 비율 → 70% 이상
- 1시간 공부 일수 / 주 7일 → 5일 이상
- 팀원 공유 메시지 수 → 주 3회 이상

> 💡 **팁**: 숫자로 표현. % 또는 횟수.

### Step 4: 안티 가치 (What NOT)
"이 4주간 절대 하지 않을 것 3개는?"

예시:
- "조급함에 5분 멈춤 건너뛰기"
- "유튜브에 2시간 이상 빠지기"
- "팀원 의견 무시하고 혼자 결정"

> 💡 **팁**: 가치의 그림자. 자주 빠지는 함정.

### Step 5: 4주 후 모습 (Vision)
"4주 후(2026-06-09) 이 북극성을 따른 결과로 무엇을 보고 싶은가?"

예시:
- "결정 의도 실행률 80% 도달"
- "공부 노트 28개 누적 → 첫 블로그 글 1개 발행"
- "팀원과의 신뢰 지표 (주관적 평가) 3 → 5점"

> 💡 **팁**: 측정 가능한 결과 + 감정/관계 결과 혼합.

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

# 사용자 이름 추출 (lifeOS_홍길동 → 홍길동)
USER_NAME=$(basename "$VAULT" | sed 's/lifeOS_//')
TODAY=$(date +%Y-%m-%d)
OUTPUT="$VAULT/04_concepts/북극성_${USER_NAME}.md"

# 이미 존재하면 백업 후 덮어쓰기 안내
if [ -f "$OUTPUT" ]; then
    echo "⚠️  기존 북극성 파일이 존재합니다."
    echo "   현재 파일: $OUTPUT"
    echo "   덮어쓰면 백업이 만들어집니다 (북극성_${USER_NAME}_${TODAY}.bak.md)."
    read -p "계속하시겠습니까? (y/N): " CONFIRM
    if [ "$CONFIRM" != "y" ]; then
        echo "취소되었습니다."
        exit 0
    fi
    cp "$OUTPUT" "$VAULT/04_concepts/북극성_${USER_NAME}_${TODAY}.bak.md"
fi

echo ""
echo "🌟 ${USER_NAME}님의 북극성 정의 워크샵을 시작합니다"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 1: 가치 3개
echo "📍 Step 1/5: 가치 3개 (Why)"
echo "   내가 인생에서 가장 중요하게 여기는 가치는?"
read -p "   가치 1: " VAL1
read -p "   가치 2: " VAL2
read -p "   가치 3: " VAL3

# Step 2: 행동 3개
echo ""
echo "📍 Step 2/5: 구체 행동 3개 (What)"
echo "   이 가치를 매일 실행하기 위한 행동은?"
read -p "   행동 1 ($VAL1): " ACT1
read -p "   행동 2 ($VAL2): " ACT2
read -p "   행동 3 ($VAL3): " ACT3

# Step 3: 측정 기준
echo ""
echo "📍 Step 3/5: 주간 체크 기준 (How)"
echo "   매주 일요일 점검할 측정 기준은?"
read -p "   기준 1: " CHK1
read -p "   기준 2: " CHK2
read -p "   기준 3: " CHK3

# Step 4: 안티 가치
echo ""
echo "📍 Step 4/5: 안티 가치 (What NOT)"
echo "   4주간 절대 하지 않을 것 3개는?"
read -p "   안티 1: " ANTI1
read -p "   안티 2: " ANTI2
read -p "   안티 3: " ANTI3

# Step 5: 4주 후 모습
echo ""
echo "📍 Step 5/5: 4주 후 모습 (Vision)"
echo "   2026-06-09에 보고 싶은 결과는? (한 문장)"
read -p "   비전: " VISION

# 파일 생성
cat > "$OUTPUT" <<EOF
# 🌟 ${USER_NAME}의 북극성

> **작성일**: $TODAY
> **유효기간**: 2026-05-19 ~ 2026-06-09 (4주, GPTers 22기 부트캠프)
> **재정의**: W4 마지막 날 피드백 후 갱신

---

## 1. 핵심 가치 3개 (Why)

1. **$VAL1**
2. **$VAL2**
3. **$VAL3**

---

## 2. 구체 행동 3개 (What)

| # | 가치 | 매일 실행할 행동 |
|---|------|----------------|
| 1 | $VAL1 | $ACT1 |
| 2 | $VAL2 | $ACT2 |
| 3 | $VAL3 | $ACT3 |

---

## 3. 주간 체크 기준 (How)

매주 일요일 \`/weekly-review\` 실행 시 자동 점검:

- [ ] $CHK1
- [ ] $CHK2
- [ ] $CHK3

---

## 4. 안티 가치 (What NOT)

4주간 절대 하지 않을 것:

- ❌ $ANTI1
- ❌ $ANTI2
- ❌ $ANTI3

---

## 5. 4주 후 모습 (Vision)

> $VISION

---

## 📌 관련 노트

- 일일 점검: \`01_daily/YYYY-MM-DD.md\` "오늘의 초점" 섹션
- 주간 점검: \`07_scratch_ai/YYYY-Wxx_주간결산.md\`
- 행동 추적: \`/focus-timer\` CSV

---

*GPTers 22기 부트캠프 W1 핵심 산출물*
*변경 이력: 작성 $TODAY*
EOF

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 북극성 정의 완료!"
echo ""
echo "📄 저장 위치:"
echo "   $OUTPUT"
echo ""
echo "📌 다음 단계:"
echo "   1. Obsidian에서 파일 열기"
echo "   2. 매일 /today 실행 시 이 북극성과 우선순위 정렬 확인"
echo "   3. 매주 /weekly-review 로 측정 기준 점검"
echo ""
echo "🌟 4주간 이 북극성을 기준으로 모든 결정을 점검하세요."
```

---

## 🎯 가이드: 좋은 북극성 vs 나쁜 북극성

| ❌ 나쁜 예 | ✅ 좋은 예 | 차이 |
|---------|---------|------|
| "행복하게 살기" | "매일 1시간 글쓰기로 깊이 만들기" | 측정 가능 |
| "성공하기" | "주간 매출 200만원 달성" | 숫자 |
| "건강하게 살기" | "주 3회 30분 러닝" | 빈도 |
| "공부 많이 하기" | "매일 25분 × 3세션 학습" | 시간 단위 |
| "좋은 부모 되기" | "퇴근 후 폰 1시간 멀리하기" | 행동 |

---

## ❓ FAQ

**Q: 가치가 4개 이상 나옵니다.**
A: 3개로 줄이세요. **선택은 곧 우선순위**입니다. 4개를 모두 안고 가면 어떤 것도 깊이 가지 못합니다.

**Q: 4주 후에 바꿔도 되나요?**
A: 네. W4 마지막 날 피드백 받고 새로 정의하세요. **4주 동안은 절대 변경 X**.

**Q: 행동이 너무 추상적이에요.**
A: "더 잘 살기" → "퇴근 후 폰 1시간 멀리하기" 같이 **동사 + 측정 가능한 숫자** 형식으로.

**Q: 안티 가치를 꼭 써야 하나요?**
A: 강력 권장. **그림자를 명시할수록 빛이 선명**해집니다.

---

## 📌 관련 스킬

- `/lifeOS-init` — 볼트 초기화 (선행)
- `/today` — 매일 우선순위 (북극성 정렬 확인)
- `/weekly-review` — 주간 점검 (W3 출시 예정)
- `/focus-timer` — 일일 실행 추적

---

*GPTers 22기 부트캠프 W1 핵심 워크샵*
*2026-05-20 폴라 작성*
