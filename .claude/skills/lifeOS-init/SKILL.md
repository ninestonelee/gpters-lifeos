---
name: lifeOS-init
description: 인생OS 볼트 빠른 시작 (새 사용자용) - Obsidian 자동 초기화
---

# 🌟 인생OS 초기화 스킬

2026-03-10 나인스톤이 시작한 인생OS 볼트를 새로운 참가자가 단 1분에 초기화하는 스킬.

## 사용 방법

`/lifeOS-init` 을 실행하면:
1. 당신의 이름 입력
2. 볼트 위치 결정 (`~/lifeOS_[name]/`)
3. 표준 폴더 구조 생성
4. 첫 데일리 노트 자동 생성
5. Obsidian 자동 실행

---

## 실행 로직

```bash
#!/bin/bash

# 색상 정의
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🌟 인생OS 초기화를 시작합니다${NC}"
echo ""

# 1. 사용자 이름 입력
read -p "당신의 이름을 입력하세요 (영문): " USER_NAME

if [ -z "$USER_NAME" ]; then
    echo "이름이 필요합니다."
    exit 1
fi

# 2. 볼트 경로 결정
VAULT_PATH="$HOME/lifeOS_${USER_NAME}"

# 기존 폴더 확인
if [ -d "$VAULT_PATH" ]; then
    echo -e "${YELLOW}⚠️ $VAULT_PATH 가 이미 존재합니다.${NC}"
    read -p "덮어쓰시겠습니까? (y/n): " CONFIRM
    if [ "$CONFIRM" != "y" ]; then
        echo "취소되었습니다."
        exit 0
    fi
fi

echo -e "${GREEN}✓ 경로: $VAULT_PATH${NC}"
echo ""

# 3. 기본 폴더 구조 생성
echo -e "${BLUE}📁 폴더 구조 생성 중...${NC}"

mkdir -p "$VAULT_PATH"/{00_inbox,01_daily,02_projects,03_people,04_concepts,05_context,06_meetings,07_scratch_ai,97_docs,98_templates,99_rules}
mkdir -p "$VAULT_PATH"/.claude/skills
mkdir -p "$VAULT_PATH"/.obsidian

echo -e "${GREEN}✓ 폴더 생성 완료${NC}"

# 4. 기본 파일들 생성

# CLAUDE.md (볼트 협업 규칙)
cat > "$VAULT_PATH"/99_rules/CLAUDE.md << 'EOF'
# 내 인생OS 규칙

## 핵심 원칙
- 데이터는 내가 소유한 기억
- 에이전트는 초안만 작성, 나는 승격을 결정
- 비밀정보(.env, API 키)는 노출 금지

## 읽기 우선순위
1. 05_context/work_context.md
2. 05_context/life_context.md
3. 최근 01_daily/ 노트
4. 활성 02_projects/ 노트

## 신뢰도 마커
- 🟢 확신: 검증됨
- 🟡 탐색중: 더 검증 필요
- 🔴 의심: 반증 있음

## 폴더명 규칙
- 프로젝트: kebab-case (예: `my-project`, `ai-agent`)
- 데일리: YYYY-MM-DD 형식

---
*생성: $(date +%Y-%m-%d)*
EOF

# 첫 데일리 노트 생성
TODAY=$(date +%Y-%m-%d)
DAY_NUMBER=1

cat > "$VAULT_PATH"/01_daily/$TODAY.md << EOF
# $TODAY — 인생OS ${DAY_NUMBER}일차 🚀

> 오늘이 인생OS를 시작하는 첫 날입니다.

## 데일리 모티브

> 오늘의 선언 · 기도 · 감사 — 하루를 여는 마음

-

---

## AI 브리핑

> \`/today\` 실행 결과가 여기에 채워집니다.

### 어제 요약
-

### 오늘의 우선순위
1. 인생OS 볼트 시스템 이해하기
2. 북극성(North Star) 정의하기
3. 첫 타이머 세션 실행해보기

### 주의할 점
- 새로운 시스템이니 천천히 적응하기

---

## 오늘의 초점

- 오늘 진짜 중요한 일은 무엇인가?

## 신호

- 무엇이 눈에 띄는가?
- 무엇이 막혀 있는가?
- 무엇이 점점 커지고 있는가?

## 일

- 활성 프로젝트:
- 회의:
- 결정:

## 아이디어

- #idea 날것의 아이디어

## 포커스 타이머

| 시간대 | 세션 | 분 | 활동 |
|--------|------|-----|------|
| | | | |

## 회고

- 오늘 생각이 어떻게 바뀌었는가?
- 무엇이 놀라웠는가?
- 내일을 위한 한 가지 배운 점?

EOF

# 05_context 초기 파일들
cat > "$VAULT_PATH"/05_context/work_context.md << EOF
# 일 컨텍스트

내가 현재 진행 중인 일들.

## 현재 핵심 프로젝트
-

## 관심 분야
-

## 진행 중인 학습
-

EOF

cat > "$VAULT_PATH"/05_context/life_context.md << EOF
# 삶 컨텍스트

내 삶의 중심이 되는 가치들.

## 북극성 (North Star)
무엇이 나의 삶을 이끌고 있는가?

-

## 핵심 가치 3가지
1.
2.
3.

## 현재 상황 스냅샷
-

EOF

# 04_concepts 초기 노트
cat > "$VAULT_PATH"/04_concepts/북극성_정의하기.md << EOF
# 나의 북극성 정의

## 가치 (Why)
내가 가장 중요하다고 생각하는 가치 3개:
-
-
-

## 구체 (What)
매일 실천할 구체적 행동:
- 예: "매 결정 전에 5분 멈춘다"
- 예: "주 1회는 산책한다"
-

## 주간 체크 기준
이번주 이 기준을 얼마나 지켰는가? (%)
다음주 개선점?

EOF

echo -e "${GREEN}✓ 기본 파일 생성 완료${NC}"

# 5. .obsidian 설정
cat > "$VAULT_PATH"/.obsidian/vault.json << 'EOF'
{
  "vaultName": "lifeOS Vault",
  "theme": "obsidian"
}
EOF

echo -e "${GREEN}✓ Obsidian 설정 완료${NC}"
echo ""

# 6. 완료 메시지
echo -e "${GREEN}✅ 인생OS 초기화 완료!${NC}"
echo ""
echo -e "${BLUE}다음 단계:${NC}"
echo "1. Obsidian에서 '$VAULT_PATH' 폴더를 열기"
echo "2. 05_context/life_context.md 에서 북극성 정의"
echo "3. 01_daily/$(date +%Y-%m-%d).md 에서 오늘 목표 기록"
echo ""

# 7. Obsidian 열기
if command -v open &> /dev/null; then
    read -p "지금 Obsidian에서 열까요? (y/n): " OPEN_OBS
    if [ "$OPEN_OBS" = "y" ]; then
        open -a Obsidian "$VAULT_PATH"
        echo -e "${GREEN}✓ Obsidian 실행 중...${NC}"
    fi
fi

echo ""
echo -e "${YELLOW}🌟 환영합니다, $USER_NAME! 인생OS와 함께 시작하세요.${NC}"
```

---

## 생성되는 구조

```
~/lifeOS_[name]/
├── 00_inbox/                    ← 빠른 캡처
├── 01_daily/                    ← 매일 기록
├── 02_projects/                 ← 프로젝트 추적
├── 03_people/                   ← 인물 노트
├── 04_concepts/                 ← 개념/북극성
├── 05_context/                  ← 일/삶 컨텍스트
├── 06_meetings/                 ← 회의 노트
├── 07_scratch_ai/               ← AI 초안
├── 97_docs/                     ← 문서
├── 98_templates/                ← 템플릿
├── 99_rules/                    ← 규칙 (CLAUDE.md)
└── .obsidian/                   ← Obsidian 설정
```

---

## 시간 제한

- 전체 실행: **1분~2분**
- 사용자 입력: 이름만 (30초)

---

## 주의사항

- 이미 폴더가 있으면 확인 메시지 표시
- Obsidian이 없으면 수동으로 열기 안내
- 모든 파일은 UTF-8로 저장

---

*이 스킬은 2026-05-19 Gpters22 W1 스터디를 위해 만들어졌습니다.*
