---
name: vault-setup
description: 인생OS 볼트 커스터마이징 - 폴더 한글화 + 템플릿 수정 + 첫 데일리 노트 생성. /lifeOS-init 이후 1회 실행.
---

# 🔧 볼트 커스터마이징 스킬

> **인생OS 17개 스킬 중 #6** (Tier 2: 기초 설정)
> **W1에서 /lifeOS-init 이후 1회 실행**

볼트 초기화가 끝났다면 **나만의 색**을 입히는 단계. 폴더명 한글화, 데일리 템플릿 수정, 첫 데일리 노트 생성을 한 번에.

---

## 사용 방법

```
/vault-setup
```

→ 3가지 선택 옵션 → 자동 적용

---

## 옵션 1: 폴더 한글화 (선택)

**기본 (영문)**:
```
00_inbox/ 01_daily/ 02_projects/ 03_people/
04_concepts/ 05_context/ 06_meetings/ 07_scratch_ai/
99_rules/
```

**한글화 후**:
```
00_받은편지함/ 01_데일리/ 02_프로젝트/ 03_사람/
04_개념/ 05_컨텍스트/ 06_회의/ 07_AI초안/
99_규칙/
```

> ⚠️ **주의**: 한글화는 한 번 결정하면 되돌리기 번거롭습니다. 영문 그대로 추천 (다른 사람과 공유 시 호환).

---

## 옵션 2: 데일리 템플릿 수정

기본 템플릿 (`98_templates/daily.md`)에 추가할 섹션:

- [ ] 감정 일기 (오늘의 감정 1~5점)
- [ ] 운동 기록 (분 단위)
- [ ] 독서 기록 (페이지)
- [ ] 식단 기록
- [ ] 수면 시간

> 💡 **팁**: 추가는 쉽지만 **줄이는 게 더 중요**. 3~5개 섹션이 최적.

---

## 옵션 3: 첫 데일리 노트 생성

오늘 날짜로 첫 데일리 노트를 만들고 Obsidian에서 자동 열기.

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

echo ""
echo "🔧 ${USER_NAME}님의 볼트 커스터마이징"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 옵션 1: 폴더 한글화
echo "📁 옵션 1: 폴더 한글화"
echo "   영문 → 한글로 폴더명 변경합니다."
echo "   예: 00_inbox → 00_받은편지함"
read -p "   한글화하시겠습니까? (y/N): " RENAME

if [ "$RENAME" = "y" ]; then
    declare -A RENAMES=(
        ["00_inbox"]="00_받은편지함"
        ["01_daily"]="01_데일리"
        ["02_projects"]="02_프로젝트"
        ["03_people"]="03_사람"
        ["04_concepts"]="04_개념"
        ["05_context"]="05_컨텍스트"
        ["06_meetings"]="06_회의"
        ["07_scratch_ai"]="07_AI초안"
        ["99_rules"]="99_규칙"
    )
    for OLD in "${!RENAMES[@]}"; do
        NEW="${RENAMES[$OLD]}"
        if [ -d "$VAULT/$OLD" ]; then
            mv "$VAULT/$OLD" "$VAULT/$NEW"
            echo "   ✓ $OLD → $NEW"
        fi
    done
    echo ""
    echo "   ⚠️  주의: 한글화 후에는 /today, /close-day 등이 새 폴더명을 자동 인식합니다."
fi

# 옵션 2: 데일리 템플릿 추가 섹션
echo ""
echo "📝 옵션 2: 데일리 템플릿 추가 섹션"
echo "   추가하고 싶은 섹션 번호를 콤마로 입력 (예: 1,3,5):"
echo "   1) 감정 일기 (1~5점)"
echo "   2) 운동 기록 (분)"
echo "   3) 독서 기록 (페이지)"
echo "   4) 식단 기록"
echo "   5) 수면 시간"
echo "   0) 추가하지 않음"
read -p "   선택: " SECTIONS

TEMPLATE_DIR=$(find "$VAULT" -maxdepth 1 -type d \( -name "98_templates" -o -name "98_템플릿" \) | head -1)
if [ -z "$TEMPLATE_DIR" ]; then
    TEMPLATE_DIR="$VAULT/98_templates"
    mkdir -p "$TEMPLATE_DIR"
fi

TEMPLATE_FILE="$TEMPLATE_DIR/daily.md"

if [ "$SECTIONS" != "0" ] && [ -n "$SECTIONS" ]; then
    ADDED=""
    IFS=',' read -ra NUMS <<< "$SECTIONS"
    for N in "${NUMS[@]}"; do
        N=$(echo "$N" | xargs)  # trim
        case "$N" in
          1) ADDED+="\n## 감정 일기\n오늘 감정 (1~5점): \n메모: \n" ;;
          2) ADDED+="\n## 운동\n종류: \n시간(분): \n" ;;
          3) ADDED+="\n## 독서\n책: \n페이지: ~  \n인사이트: \n" ;;
          4) ADDED+="\n## 식단\n아침: \n점심: \n저녁: \n" ;;
          5) ADDED+="\n## 수면\n취침: \n기상: \n수면 시간: \n" ;;
        esac
    done
    if [ -n "$ADDED" ]; then
        echo -e "$ADDED" >> "$TEMPLATE_FILE"
        echo "   ✓ 템플릿에 섹션 추가 완료: $TEMPLATE_FILE"
    fi
fi

# 옵션 3: 첫 데일리 노트
echo ""
echo "📅 옵션 3: 첫 데일리 노트 생성"
read -p "   오늘($TODAY) 데일리 노트를 만들까요? (Y/n): " MAKE_DAILY

DAILY_DIR=$(find "$VAULT" -maxdepth 1 -type d \( -name "01_daily" -o -name "01_데일리" \) | head -1)
if [ -z "$DAILY_DIR" ]; then
    DAILY_DIR="$VAULT/01_daily"
    mkdir -p "$DAILY_DIR"
fi

DAILY_FILE="$DAILY_DIR/$TODAY.md"

if [ "$MAKE_DAILY" != "n" ]; then
    if [ -f "$DAILY_FILE" ]; then
        echo "   ⚠️  이미 존재: $DAILY_FILE"
    else
        if [ -f "$TEMPLATE_FILE" ]; then
            cp "$TEMPLATE_FILE" "$DAILY_FILE"
            sed -i.bak "s/{{title}}/$TODAY/g" "$DAILY_FILE" && rm -f "$DAILY_FILE.bak"
        else
            cat > "$DAILY_FILE" <<EOF
# $TODAY

## 오늘의 초점

## 일

## 회고

EOF
        fi
        echo "   ✓ 생성: $DAILY_FILE"
    fi

    # Obsidian 자동 열기
    if command -v open &> /dev/null; then
        open "$DAILY_FILE" 2>/dev/null && echo "   ✓ Obsidian에서 열기 시도"
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 볼트 커스터마이징 완료!"
echo ""
echo "📌 다음 단계:"
echo "   1. /north-star-define 으로 북극성 작성"
echo "   2. /focus-timer start \"활동명\" 으로 첫 세션 시작"
echo "   3. 저녁 /close-day 로 하루 마감"
echo ""
```

---

## ❓ FAQ

**Q: 한글화하면 영문으로 되돌릴 수 있나요?**
A: 같은 스킬을 다시 실행하면 옵션 1에서 No를 선택하고 수동 `mv` 또는 Obsidian에서 폴더 이름 변경.

**Q: 템플릿에 너무 많이 추가했어요. 어떻게 줄이나요?**
A: `~/lifeOS_[name]/98_templates/daily.md` 파일을 Obsidian에서 직접 편집.

**Q: 첫 데일리 노트를 만들었는데 Obsidian이 안 열려요.**
A: 수동으로 Obsidian을 열고 볼트 폴더(`~/lifeOS_[name]/`)를 선택하세요.

---

## 📌 관련 스킬

- `/lifeOS-init` — 볼트 초기화 (선행 필수)
- `/north-star-define` — 북극성 작성 (다음 단계)
- `/today` — 매일 아침 루틴
- `/close-day` — 매일 저녁 마감

---

*GPTers 22기 부트캠프 W1 보조 스킬*
*2026-05-20 폴라 작성*
