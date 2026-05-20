# 🌟 인생OS (Life OS) - GPTers 22기

> Obsidian × Claude Code로 만드는 **세컨드 브레인** + **AI 참모 에이전트**

**지피터스 AI스터디 22기** "1인 기업가를 위한 클로드 코드로 AI 참모와 인생OS 만들기" 과정용 완전 자동화 Obsidian 볼트 + 17개 스킬 패키지입니다.

---

## 🚀 설치 (1분)

### 방법 1: GitHub 스킬 일괄 설치 (⭐ 가장 추천)

**Mac / Linux:**
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ninestonelee/gpters-lifeos/main/install-skill.sh)
```

**Windows (PowerShell):**
```powershell
curl.exe -fsSL https://raw.githubusercontent.com/ninestonelee/gpters-lifeos/main/install-skill.sh | wsl bash
```

> **WSL이 필요합니다.** [WSL 설치 가이드](#wsl-설치-가이드-windows-전용) 참조

설치 후:
1. Claude Code 재시작 (또는 `/reload-skills` 실행)
2. `/lifeOS-init` 으로 볼트 생성
3. `/north-star-define` 으로 북극성 작성
4. `/today` 와 `/close-day` 로 일일 루틴 시작

---

## 📦 설치되는 스킬 (W2 직전 — 6개)

| # | 스킬 | Tier | 언제 사용? | 가이드 섹션 |
|---|------|------|----------|------------|
| 1 | `/today` | 1 (일일) | 매일 아침 7~8시 | [→ 상세](#1-today) |
| 2 | `/close-day` | 1 (일일) | 매일 저녁 22~23시 | [→ 상세](#2-close-day) |
| 3 | `/focus-timer` | 1 (일일) | 수시 (start/stop/log) | [→ 상세](#3-focus-timer) |
| 4 | `/lifeOS-init` | 2 (기초) | W1 첫날 1회 | [→ 상세](#4-lifeos-init) |
| 5 | `/north-star-define` | 2 (기초) | W1 강의 중 1회 | [→ 상세](#5-north-star-define) |
| 6 | `/vault-setup` | 2 (기초) | W1 이후 1회 | [→ 상세](#6-vault-setup) |

> 📅 **단계적 출시**:
> - **W2 직전 (~5/25)**: 위 6개 (Tier 1~2) ← 현재
> - **W3 직전 (~6/1)**: +6개 (Tier 3~4 의사결정/AI 협업)
> - **W4 직전 (~6/8)**: +5개 (Tier 5~6 기억 보존/팀 운영)
> - **최종**: 17개 스킬 완성

---

## 📚 볼트 구조

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
- `04_concepts/북극성_[name].md` — W1에서 작성, 4주간 의사결정 기준
- `05_context/work_context.md` — 당신의 일과 목표
- `07_scratch_ai/YYYY-MM-DD_에세이.md` — 매일 저녁 회고

---

## 🎓 4주 커리큘럼

| 주차 | 날짜 | 주제 | 사용 스킬 |
|------|------|------|---------|
| **W1** | 5/19 | 북극성 정의 + 일일 루틴 | /lifeOS-init, /vault-setup, /north-star-define, /today, /focus-timer, /close-day |
| **W2** | 5/26 | AI 참모 온보딩 | + /decision-log, /pola-briefing, /delegate (출시 예정) |
| **W3** | 6/2 | 주간 루틴 + 블로그 | + /weekly-review, /blocker-unblock, /gallery-organize (출시 예정) |
| **W4** | 6/9 | 콘트롤타워 + 최종 발표 | + /agent-onboard, /team-standup, /monthly-archive (출시 예정) |

---

## 🔧 스킬 상세 가이드

### 1. /today
**매일 아침 7~8시** 실행하는 일일 루틴 시작 스킬.

**자동 수행**:
- 오늘 데일리 노트 생성 (`01_daily/YYYY-MM-DD.md`)
- 어제 회고 요약 + 최근 7일 미완료 항목 추출
- 북극성 노트 참조 → 우선순위 가이드 생성
- AI 브리핑 섹션 자동 갱신
- Obsidian에서 오늘 노트 자동 열기

### 2. /close-day
**매일 저녁 22~23시** 실행하는 일일 마감 스킬.

**자동 수행**:
- 진행 중 포커스 타이머 세션 자동 종료
- CSV 결산 → 데일리 노트 `## 포커스 타이머` 섹션 표 자동 삽입
- 시간대별 집계 (오전/오후/저녁/합계)
- 회고 가이드 3개 질문 표시
- 에세이 템플릿 자동 생성 (`07_scratch_ai/YYYY-MM-DD_에세이.md`)

### 3. /focus-timer
**수시 실행** — 25분 집중 세션을 추적하는 스킬.

```bash
/focus-timer start "북극성 정의"  # 세션 시작
/focus-timer stop                # 세션 종료 + CSV 저장
/focus-timer log                 # 오늘 결산 보기
```

**자동 수행**:
- 시작 시간 기록 → state 파일 저장
- 종료 시 실제 소요 시간 자동 계산 (자정 넘김 보정 포함)
- `01_daily/focus_timer_YYYYMMDD.csv` 누적 저장
- `/close-day` 실행 시 자동 결산

### 4. /lifeOS-init
**W1 첫날 1회** 실행하는 볼트 초기화 스킬.

**자동 수행**:
- 이름 입력 → `~/lifeOS_[name]/` 볼트 자동 생성
- 9개 표준 폴더 + 템플릿 자동 설치
- 첫 데일리 노트 생성
- Obsidian 자동 열기

### 5. /north-star-define
**W1 강의 중 1회** 실행하는 북극성 정의 워크샵 스킬.

**5단계 대화형 진행**:
1. 핵심 가치 3개 (Why)
2. 구체 행동 3개 (What)
3. 주간 체크 기준 (How)
4. 안티 가치 3개 (What NOT)
5. 4주 후 모습 (Vision)

**산출물**: `04_concepts/북극성_[name].md` — 4주간 모든 의사결정의 기준.

### 6. /vault-setup
**W1 이후 1회** 실행하는 볼트 커스터마이징 스킬.

**3가지 옵션 선택**:
- 폴더 한글화 (00_inbox → 00_받은편지함)
- 데일리 템플릿 추가 섹션 (감정/운동/독서/식단/수면)
- 첫 데일리 노트 자동 생성

---

## ⏱️ 권장 일일 흐름

```
07:30  /today              ← 오늘 우선순위 확인
08:00  /focus-timer start "1번 활동"
08:25  /focus-timer stop
10:00  /focus-timer start "2번 활동"
...
21:00  /focus-timer log    ← 하루 결산 미리보기
22:00  /close-day          ← 회고 + 에세이
```

---

## 🟢 시작하기 (Step-by-Step)

### Step 1: 스킬 설치
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ninestonelee/gpters-lifeos/main/install-skill.sh)
```

### Step 2: Claude Code 재시작
6개 스킬이 자동으로 인식됩니다.

### Step 3: 볼트 초기화
```bash
/lifeOS-init
# → 이름 입력 (영문)
# → ~/lifeOS_[name]/ 자동 생성
```

### Step 4: 북극성 작성 (W1 강의 중)
```bash
/north-star-define
# → 5단계 워크샵 진행
# → ~/lifeOS_[name]/04_concepts/북극성_[name].md 생성
```

### Step 5: 첫 일일 루틴
```bash
/today              # 아침
/focus-timer start "북극성 점검"
/focus-timer stop
/close-day          # 저녁
```

---

## WSL 설치 가이드 (Windows 전용)

### 시스템 요구사항
- **Windows 10** Build 2004 이상 또는 **Windows 11**
- 관리자 권한

### 설치 단계

#### 1️⃣ PowerShell을 관리자로 실행
- `Win + X` → "Windows PowerShell (관리자)" 클릭

#### 2️⃣ WSL 및 Ubuntu 설치
```powershell
wsl --install
```
- 기본값으로 Ubuntu Linux가 설치됩니다
- 설치 후 컴퓨터 재부팅

#### 3️⃣ Ubuntu 첫 실행
```powershell
wsl
```
- 사용자명과 비밀번호 설정 (기억해두세요)
- `exit` 또는 `Ctrl+D`로 WSL 종료

#### 4️⃣ 설치 확인
```powershell
wsl --list --verbose
```
- Ubuntu 상태가 "Running"이면 성공

### 더 알아보기
- [Microsoft WSL 공식 가이드](https://learn.microsoft.com/en-us/windows/wsl/install)
- WSL 2로 자동 설정됩니다 (권장)

---

## 🤝 지원

- **문제 발생**: [GitHub Issues](https://github.com/ninestonelee/gpters-lifeos/issues)
- **피드백**: [Discussions](https://github.com/ninestonelee/gpters-lifeos/discussions)
- **지피터스 커뮤니티**: [GPTers 슬랙](https://gpters.org)

---

## 📝 라이선스

MIT License — 자유롭게 사용, 수정, 배포 가능합니다.

---

**2026년 5월 19일 ~ 6월 9일** · 지피터스 22기 부트캠프
**제작**: 나인스톤 × 폴라 (Claude Code Agent)
**스킬 패키지 v0.2** (2026-05-20, W2 직전 6개 출시분)
