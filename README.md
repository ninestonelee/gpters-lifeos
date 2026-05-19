# 🌟 인생OS (Life OS) - GPTers 22기

> Obsidian × Claude Code로 만드는 **세컨드 브레인** + **AI 참모 에이전트**

**지피터스 AI스터디 22기** "1인 기업가를 위한 클로드 코드로 AI 참모와 인생OS 만들기" 과정용 완전 자동화 Obsidian 볼트 초기화 도구입니다.

---

## 🚀 설치 (1분)

### 방법 1: GitHub 스킬 설치 (⭐ 가장 추천)

**Mac / Linux / WSL:**
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ninestonelee/gpters-lifeos/main/install-skill.sh)
```

**Windows (Git Bash 또는 WSL 필수):**
- **WSL 설치된 경우** (권장):
  ```bash
  wsl bash <(curl -fsSL https://raw.githubusercontent.com/ninestonelee/gpters-lifeos/main/install-skill.sh)
  ```
- **Git Bash 설치된 경우**:
  ```bash
  bash <(curl -fsSL https://raw.githubusercontent.com/ninestonelee/gpters-lifeos/main/install-skill.sh)
  ```
- **Neither 설치 안 됨**: [방법 3: 수동 설치](#방법-3-수동-설치-고급-사용자)로 진행

설치 후:
1. Claude Code 재시작 (또는 `/reload-skills` 실행)
2. `/lifeOS-init` 명령어 실행
3. 이름 입력 → Obsidian 자동 생성

### 방법 2: Claude Code 스킬 (설치 완료 후)

Claude Code에서 직접 실행:
```bash
/lifeOS-init
```

### 방법 3: 수동 설치 (고급 사용자)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ninestonelee/gpters-lifeos/main/lifeOS-init.sh)
```

---

## 📚 포함 내용

설치 후 다음이 자동 생성됩니다:

```
~/lifeOS_[yourname]/
├── 00_inbox/                 ← 빠른 캡처
├── 01_daily/                 ← 매일 기록 (템플릿 포함)
├── 02_projects/              ← 프로젝트 추적
├── 03_people/                ← 인물 노트
├── 04_concepts/              ← 북극성 + 개념
├── 05_context/               ← 일/삶 컨텍스트
├── 06_meetings/              ← 회의 노트
├── 07_scratch_ai/            ← AI 초안 영역
├── 99_rules/                 ← 협업 규칙 (CLAUDE.md)
└── .obsidian/                ← Obsidian 설정
```

**핵심 파일들:**
- `01_daily/YYYY-MM-DD.md` — 매일 아침 자동 생성
- `05_context/work_context.md` — 당신의 일과 목표
- `05_context/life_context.md` — 북극성(North Star) 정의
- `04_concepts/북극성_[name].md` — W1 첫 강의에서 작성

---

## 🎓 4주 커리큘럼

| 주차 | 주제 | 날짜 | 목표 |
|------|------|------|------|
| **W1** | 북극성 정의 + 일일 루틴 | 5/19 | 첫 북극성 노트 작성 |
| **W2** | AI 참모 온보딩 | 5/26 | 의사결정 자동화 |
| **W3** | 주간 루틴 + 블로그 | 6/2 | 28일 데일리 완성 |
| **W4** | 콘트롤타워 + 최종 발표 | 6/9 | 4주 에세이 발표 |

---

## 🔧 주요 기능

### 1️⃣ 일일 리뷰 (`/today`)
어제 요약 + 오늘 우선순위를 자동으로 생성합니다.

### 2️⃣ 하루 마감 (`/close-day`)
포커스 타이머 + 작업 결산 + 에세이를 자동으로 정리합니다.

### 3️⃣ 포커스 타이머
북극성에 맞는 매일 5개 결정을 추적합니다.

---

## 🟢 시작하기

1. **스킬 실행**
   ```bash
   /lifeOS-init
   ```

2. **이름 입력**
   ```
   당신의 이름을 입력하세요 (영문): [your name]
   ```

3. **Obsidian 열기**
   - 자동으로 열리거나, 수동으로 `~/lifeOS_[name]` 폴더 열기

4. **첫 작업: 북극성 정의**
   - `05_context/life_context.md` 작성 (가치 3개)
   - `04_concepts/북극성_[name].md` 작성 (W1에서 발표할 내용)

---

## 🤝 지원

- **문제 발생**: [GitHub Issues](https://github.com/ninestonelee/gpters-lifeos/issues)
- **피드백**: [Discussions](https://github.com/ninestonelee/gpters-lifeos/discussions)
- **지피터스 커뮤니티**: [GPTers 슬랙](https://gpters.org)

---

## 📝 라이선스

MIT License — 자유롭게 사용, 수정, 배포 가능합니다.

---

**2026년 5월 19일** · 지피터스 22기 부트캠프  
**제작**: 나인스톤 × 폴라 (Claude Code Agent)
