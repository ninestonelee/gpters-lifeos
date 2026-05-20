#!/bin/bash

# 색상 정의
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

REPO_BASE="https://raw.githubusercontent.com/ninestonelee/gpters-lifeos/main"
SKILLS_DIR="$HOME/.claude/skills"

# W2 직전 출시 스킬 6개 (Tier 1~2)
# 출시 단계가 늘어나면 아래 배열에 추가만 하면 됨
SKILLS=(
    "lifeOS-init"
    "today"
    "close-day"
    "focus-timer"
    "north-star-define"
    "vault-setup"
)

echo -e "${BLUE}🌟 인생OS 스킬 설치를 시작합니다${NC}"
echo -e "${BLUE}   총 ${#SKILLS[@]}개 스킬 (Tier 1~2)${NC}"
echo ""

# 스킬 디렉토리 생성
if [ ! -d "$SKILLS_DIR" ]; then
    echo -e "${BLUE}📁 $SKILLS_DIR 디렉토리 생성 중...${NC}"
    mkdir -p "$SKILLS_DIR"
    echo -e "${GREEN}✓ 디렉토리 생성 완료${NC}"
    echo ""
fi

# 설치 결과 추적
INSTALLED=()
FAILED=()
SKIPPED=()

# 각 스킬 설치
for SKILL_NAME in "${SKILLS[@]}"; do
    SKILL_DIR="$SKILLS_DIR/$SKILL_NAME"
    SKILL_PATH="$SKILL_DIR/SKILL.md"
    SKILL_URL="$REPO_BASE/.claude/skills/$SKILL_NAME/SKILL.md"

    mkdir -p "$SKILL_DIR"

    echo -e "${BLUE}⬇️  [$SKILL_NAME] 다운로드 중...${NC}"

    if curl -fsSL "$SKILL_URL" -o "$SKILL_PATH" 2>/dev/null; then
        # 파일이 비어있거나 GitHub 404 페이지인지 확인
        if [ -s "$SKILL_PATH" ] && ! grep -q "404: Not Found" "$SKILL_PATH" 2>/dev/null; then
            echo -e "${GREEN}   ✓ $SKILL_NAME 설치 완료${NC}"
            INSTALLED+=("$SKILL_NAME")
        else
            echo -e "${YELLOW}   ⚠ $SKILL_NAME 아직 출시 전 (W3/W4에서 추가 예정)${NC}"
            rm -f "$SKILL_PATH"
            SKIPPED+=("$SKILL_NAME")
        fi
    else
        echo -e "${RED}   ❌ $SKILL_NAME 다운로드 실패${NC}"
        FAILED+=("$SKILL_NAME")
    fi
done

# 기존 flat file 정리 (구버전 호환)
OLD_SKILL_PATH="$SKILLS_DIR/lifeOS-init.md"
if [ -f "$OLD_SKILL_PATH" ]; then
    rm "$OLD_SKILL_PATH"
    echo ""
    echo -e "${BLUE}📁 구버전 lifeOS-init.md 파일 정리 완료${NC}"
fi

# 결과 요약
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ 설치 완료: ${#INSTALLED[@]}개${NC}"
for s in "${INSTALLED[@]}"; do
    echo -e "   ${GREEN}•${NC} /$s"
done

if [ ${#SKIPPED[@]} -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}⏭️  대기 중: ${#SKIPPED[@]}개 (다음 주차에 출시)${NC}"
    for s in "${SKIPPED[@]}"; do
        echo -e "   ${YELLOW}•${NC} /$s"
    done
fi

if [ ${#FAILED[@]} -gt 0 ]; then
    echo ""
    echo -e "${RED}❌ 설치 실패: ${#FAILED[@]}개${NC}"
    for s in "${FAILED[@]}"; do
        echo -e "   ${RED}•${NC} /$s"
    done
    echo -e "${YELLOW}   인터넷 연결을 확인하고 다시 시도하세요.${NC}"
fi
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${BLUE}다음 단계:${NC}"
echo "1. Claude Code 재시작 (또는 /reload-skills 실행)"
echo "2. /lifeOS-init 명령어로 볼트 초기화"
echo "3. /north-star-define 으로 북극성 작성 (W1 강의 중)"
echo "4. /today 와 /close-day 로 일일 루틴 시작"
echo ""
echo -e "${YELLOW}🌟 수강생 여러분, 인생OS의 여정을 시작하세요!${NC}"
