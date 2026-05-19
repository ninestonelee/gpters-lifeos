#!/bin/bash

# 색상 정의
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 lifeOS-init 스킬 설치를 시작합니다${NC}"
echo ""

# Claude Code 스킬 디렉토리 확인
SKILLS_DIR="$HOME/.claude/skills"

# 디렉토리 생성 (없으면)
if [ ! -d "$SKILLS_DIR" ]; then
    echo -e "${BLUE}📁 $SKILLS_DIR 디렉토리 생성 중...${NC}"
    mkdir -p "$SKILLS_DIR"
    echo -e "${GREEN}✓ 디렉토리 생성 완료${NC}"
fi

# 스킬 디렉토리 생성
SKILL_DIR="$SKILLS_DIR/lifeOS-init"
mkdir -p "$SKILL_DIR"

# 스킬 파일 다운로드
echo -e "${BLUE}⬇️  스킬 파일 다운로드 중...${NC}"
SKILL_URL="https://raw.githubusercontent.com/ninestonelee/gpters-lifeos/main/.claude/skills/lifeOS-init/SKILL.md"
SKILL_PATH="$SKILL_DIR/SKILL.md"

if curl -fsSL "$SKILL_URL" -o "$SKILL_PATH"; then
    echo -e "${GREEN}✓ 스킬 파일 다운로드 완료${NC}"
else
    echo -e "${RED}❌ 스킬 파일 다운로드 실패${NC}"
    echo "URL: $SKILL_URL"
    exit 1
fi

# 기존 flat file 제거 (호환성)
OLD_SKILL_PATH="$SKILLS_DIR/lifeOS-init.md"
if [ -f "$OLD_SKILL_PATH" ]; then
    rm "$OLD_SKILL_PATH"
    echo -e "${BLUE}📁 기존 파일 정리 완료${NC}"
fi

# 설치 완료 메시지
echo ""
echo -e "${GREEN}✅ lifeOS-init 스킬 설치 완료!${NC}"
echo ""
echo -e "${BLUE}다음 단계:${NC}"
echo "1. Claude Code 재시작 (또는 /reload-skills 실행)"
echo "2. /lifeOS-init 명령어 실행"
echo ""
echo -e "${YELLOW}🌟 수강생 여러분, 이제 /lifeOS-init으로 인생OS 볼트를 초기화하세요!${NC}"
