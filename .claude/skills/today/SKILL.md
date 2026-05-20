---
name: today
description: 인생OS 아침 루틴 - 어제 요약 + 오늘 우선순위 AI 브리핑 + 데일리 노트 자동 생성. 매일 아침 7~8시 실행.
---

# 🌅 아침 루틴 스킬

> **인생OS 17개 스킬 중 #1** (Tier 1: 일일 루틴)
> **매일 아침 7~8시** 1회 실행

어제 요약 + 오늘 우선순위 + AI 브리핑을 한 번에. 데일리 노트가 자동 생성됩니다.

---

## 사용 방법

```
/today
```

→ 다음을 자동 수행:
1. `~/lifeOS_[name]/01_daily/YYYY-MM-DD.md` 생성 (오늘 데일리 노트)
2. 어제 데일리 노트 읽기 → 어제 회고 요약
3. 최근 7일 데일리에서 반복 테마 + 미완료 항목 추출
4. 북극성 노트(`04_concepts/북극성_*.md`) 참조
5. **AI 브리핑** 섹션에 우선순위 3개 작성
6. Obsidian에서 오늘 노트 자동 열기

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
YESTERDAY=$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d "yesterday" +%Y-%m-%d)

# 폴더 자동 탐색 (영문/한글 둘 다)
DAILY_DIR=$(find "$VAULT" -maxdepth 1 -type d \( -name "01_daily" -o -name "01_데일리" \) | head -1)
[ -z "$DAILY_DIR" ] && DAILY_DIR="$VAULT/01_daily" && mkdir -p "$DAILY_DIR"

TEMPLATE_DIR=$(find "$VAULT" -maxdepth 1 -type d \( -name "98_templates" -o -name "98_템플릿" \) | head -1)
TEMPLATE="$TEMPLATE_DIR/daily.md"

TODAY_FILE="$DAILY_DIR/$TODAY.md"
YESTERDAY_FILE="$DAILY_DIR/$YESTERDAY.md"

echo ""
echo "🌅 ${USER_NAME}님의 오늘 ($TODAY)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. 오늘 데일리 노트 생성 (없으면)
if [ ! -f "$TODAY_FILE" ]; then
    if [ -f "$TEMPLATE" ]; then
        cp "$TEMPLATE" "$TODAY_FILE"
        # macOS/Linux 호환 sed
        sed -i.bak "s/{{title}}/$TODAY/g" "$TODAY_FILE" 2>/dev/null && rm -f "$TODAY_FILE.bak"
    else
        cat > "$TODAY_FILE" <<EOF
# $TODAY

## AI 브리핑

## 오늘의 초점

## 일

## 회고

EOF
    fi
    echo "✓ 데일리 노트 생성: $TODAY_FILE"
else
    echo "ℹ️  데일리 노트 이미 존재 (AI 브리핑 섹션만 갱신)"
fi

echo ""
echo "📊 컨텍스트 수집:"

# 2. 어제 데일리 노트 읽기
if [ -f "$YESTERDAY_FILE" ]; then
    echo "   ✓ 어제($YESTERDAY) 노트 확인"
    YESTERDAY_SUMMARY=$(grep -A 3 "## 회고" "$YESTERDAY_FILE" 2>/dev/null | tail -3 | head -3)
else
    echo "   ⚠ 어제($YESTERDAY) 노트 없음"
    YESTERDAY_SUMMARY="(어제 노트 없음 — /today 첫 실행이거나 어제 close-day를 안 한 듯합니다)"
fi

# 3. 최근 7일 미완료 항목 검색
RECENT_TODOS=$(find "$DAILY_DIR" -name "*.md" -newermt "7 days ago" 2>/dev/null \
    | xargs grep -h "^- \[ \]" 2>/dev/null | head -5)

# 4. 북극성 노트 읽기
NORTH_STAR=$(find "$VAULT" -path "*/04_concepts/*" -name "북극성_*.md" 2>/dev/null | head -1)
NORTH_STAR_HEAD=""
if [ -n "$NORTH_STAR" ]; then
    echo "   ✓ 북극성 참조: $(basename $NORTH_STAR)"
    NORTH_STAR_HEAD=$(head -20 "$NORTH_STAR" | grep -E "^[\-1-3]\.|^- " | head -3)
else
    echo "   ⚠ 북극성 미작성 — /north-star-define 실행 권장"
fi

# 5. 어제 포커스 타이머 분석
YESTERDAY_CSV="$DAILY_DIR/focus_timer_$(date -v-1d +%Y%m%d 2>/dev/null || date -d "yesterday" +%Y%m%d).csv"
if [ -f "$YESTERDAY_CSV" ]; then
    SESSIONS=$(($(wc -l < "$YESTERDAY_CSV") - 1))
    TOTAL_MIN=$(awk -F, 'NR>1 {sum+=$4} END {print sum}' "$YESTERDAY_CSV")
    echo "   ✓ 어제 포커스: ${SESSIONS}세션, ${TOTAL_MIN}분"
fi

# 6. AI 브리핑 섹션 갱신
# 기존 ## AI 브리핑 섹션을 찾아서 다음 ## 까지 교체
BRIEFING=$(cat <<EOF
## AI 브리핑 (자동 생성: $(date +%H:%M))

### 어제 요약
$YESTERDAY_SUMMARY

### 오늘 우선순위 (북극성 정렬 기준)
1. (수동 입력 — 북극성을 보고 가장 중요한 1가지)
2. (수동 입력 — 두 번째)
3. (수동 입력 — 세 번째)

### 최근 7일 미완료
$RECENT_TODOS

### 북극성 행동 점검
$NORTH_STAR_HEAD

> 💡 **시작 권장**: /focus-timer start "위 1번 활동"
EOF
)

# AI 브리핑 섹션 갱신 (있으면 교체, 없으면 상단에 추가)
if grep -q "^## AI 브리핑" "$TODAY_FILE"; then
    # macOS sed로 섹션 교체는 까다로움 — Python으로 처리
    python3 - "$TODAY_FILE" <<PYEOF
import sys, re
fn = sys.argv[1]
with open(fn, 'r') as f:
    content = f.read()

briefing = """$BRIEFING"""

# ## AI 브리핑 부터 다음 ## 직전까지 교체
pattern = r'## AI 브리핑.*?(?=\n## |\Z)'
new_content = re.sub(pattern, briefing.strip() + '\n\n', content, count=1, flags=re.DOTALL)

with open(fn, 'w') as f:
    f.write(new_content)
PYEOF
else
    # 파일 상단(첫 # 다음)에 삽입
    echo "$BRIEFING" >> "$TODAY_FILE"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 오늘 ($TODAY) 준비 완료"
echo ""
echo "📌 다음 단계:"
echo "   1. Obsidian에서 데일리 노트 열기"
echo "   2. AI 브리핑 → 우선순위 3개 수동 입력"
echo "   3. /focus-timer start \"첫 활동\" 으로 시작"
echo ""

# Obsidian 자동 열기
if command -v open &> /dev/null; then
    open "$TODAY_FILE" 2>/dev/null
fi
```

---

## 📋 출력 형식 예시

`~/lifeOS_홍길동/01_daily/2026-05-26.md`:

```markdown
# 2026-05-26

## AI 브리핑 (자동 생성: 07:32)

### 어제 요약
- 북극성 정의 워크샵 완료
- 포커스 타이머 3세션 (75분)
- 막힘 1건: Claude Code 설치

### 오늘 우선순위 (북극성 정렬 기준)
1. Claude Code 설치 완료
2. 첫 /focus-timer 세션 5개 채우기
3. W2 강의 자료 사전 점검

### 최근 7일 미완료
- [ ] 북극성 노트 작성
- [ ] Obsidian 첫 설치

### 북극성 행동 점검
1. 의도 — 매 결정 전 5분 멈춤
2. 학습 — 하루 1시간 공부
3. 기여 — 팀원 1명 공유

> 💡 시작 권장: /focus-timer start "Claude Code 설치 완료"

## 오늘의 초점

## 일

## 회고
```

---

## ❓ FAQ

**Q: 매일 같은 시간에 실행해야 하나요?**
A: 권장은 아침 7~8시. 점심에 실행해도 동작합니다 (AI 브리핑 시간만 갱신).

**Q: 데일리 노트를 수동으로 만들었는데 /today를 실행하면 덮어쓰나요?**
A: 아니요. `## AI 브리핑` 섹션만 자동 갱신됩니다. 다른 섹션은 보존.

**Q: 어제 close-day를 안 했어요. /today가 작동하나요?**
A: 네. 어제 노트가 없으면 "(어제 노트 없음)"으로 표시되고 정상 진행됩니다.

**Q: 북극성을 아직 안 만들었어요.**
A: /today는 작동합니다. 다만 "북극성 미작성" 경고가 표시되니, 빠른 시일 내 `/north-star-define` 권장.

---

## 📌 관련 스킬

- `/lifeOS-init` — 볼트 초기화 (선행 필수)
- `/north-star-define` — 북극성 정의 (선행 권장)
- `/focus-timer` — 우선순위 실행 추적
- `/close-day` — 저녁 마감 (오늘 노트 회고 + 내일 데이터 준비)

---

*GPTers 22기 부트캠프 W1 일일 루틴 #1*
*2026-05-20 폴라 작성*
