---
name: agent-setup
description: 인생OS AI 참모(에이전트) 설정 - 나만의 AI 참모 페르소나(이름·호칭·톤·역할)를 대화형으로 정의해 볼트 CLAUDE.md에 안전하게 기록. 기존 설정은 덮어쓰기 전 반드시 확인(비파괴적). 첫 설정 또는 업데이트 시 선택 실행.
---

# 🤖 AI 참모 설정 스킬

> **인생OS 17개 스킬 중 #16** (Tier 6: 팀 운영)
> **첫 설정 1회 + 원할 때** (선택적)

나만의 AI 참모(예: 나인스톤의 "폴라")를 대화형으로 설정합니다. 이름·호칭·톤·역할을 정해 볼트의 `CLAUDE.md`에 기록하면, 이후 모든 세션에서 Claude가 그 페르소나로 일합니다.

> ⚠️ **비파괴적 설계**: 이미 설정된 페르소나가 있으면 **절대 자동으로 덮어쓰지 않습니다.** 현재 설정을 보여주고 "유지/수정/교체" 중 선택받습니다. 업데이트로 기존 사용자의 설정이 날아가지 않습니다.

---

## 사용 방법

```
/agent-setup
```

→ Claude가 다음 순서로 진행:
1. **기존 페르소나 감지** (`CLAUDE.md`의 AGENT 블록)
   - 있으면 → 현재 설정을 보여주고 **유지(기본)/수정/교체** 질문 (덮어쓰기 금지)
   - 없으면 → 신규 설정 진행
2. **대화형 질문 4가지**: 참모 이름 · 나를 부르는 호칭 · 말투/톤 · 역할/전문분야
3. **미리보기** → 사용자 확인
4. `CLAUDE.md`의 **AGENT 블록만** 갱신 (나머지 내용 보존)

---

## 🤖 Claude 실행 가이드 (이 스킬은 대화형입니다)

### Step 1 — 기존 설정 감지

볼트 `CLAUDE.md`에서 `<!-- LIFEOS-AGENT:START -->` ~ `<!-- LIFEOS-AGENT:END -->` 블록을 찾는다.

```bash
# 볼트 탐색
if [ -n "$LIFEOS_VAULT" ] && [ -d "$LIFEOS_VAULT" ]; then VAULT="$LIFEOS_VAULT"; else VAULT=$(find "$HOME" -maxdepth 1 -type d -name "lifeOS_*" 2>/dev/null | head -1); fi
CLAUDE_MD="$VAULT/CLAUDE.md"

if [ -f "$CLAUDE_MD" ] && grep -q "LIFEOS-AGENT:START" "$CLAUDE_MD"; then
    echo "EXISTING"
    awk '/LIFEOS-AGENT:START/{f=1} f{print} /LIFEOS-AGENT:END/{f=0}' "$CLAUDE_MD"
else
    echo "NEW"
fi
```

- **`EXISTING`이면**: 현재 페르소나를 사용자에게 보여주고 다음을 AskUserQuestion으로 묻는다 —
  "이미 AI 참모가 설정돼 있어요. 어떻게 할까요?"
  - **그대로 유지** (기본·권장) → 아무것도 바꾸지 않고 종료
  - **일부 수정** → 바꿀 항목만 다시 질문
  - **완전히 교체** → 신규 설정 진행 (단, 교체 확정 1회 더 확인)
- **`NEW`이면**: 바로 Step 2.

> 🔒 절대 규칙: 사용자가 "수정/교체"를 **명시적으로 선택하지 않으면** CLAUDE.md를 건드리지 않는다.

### Step 2 — 대화형 질문 (AskUserQuestion 권장)

1. **참모 이름** — AI 참모를 뭐라고 부를까요? (예: 폴라, 자비스, 비서님)
2. **나를 부르는 호칭** — 참모가 나를 어떻게 부를까요? (예: 대표님, 이름, 닉네임)
3. **말투/톤** — 어떤 말투가 좋아요? (예: 친근한 동료체 / 정중한 비서체 / 직설적 코치체)
4. **역할/전문분야** — 주로 뭘 도와줄 참모인가요? (예: 1인 사업 전략, 콘텐츠 기획, 개발)

### Step 3 — 미리보기 + 확인

수집한 값으로 아래 블록을 만들어 사용자에게 보여주고 "이대로 저장할까요?" 확인받는다.

### Step 4 — CLAUDE.md AGENT 블록만 안전 기록

```bash
# 변수: NAME, CALL(호칭), TONE, ROLE  (Step 2에서 수집)
VAULT="${VAULT:?}"; CLAUDE_MD="$VAULT/CLAUDE.md"
BLOCK_FILE=$(mktemp)
cat > "$BLOCK_FILE" <<BLOCK
<!-- LIFEOS-AGENT:START (이 블록은 /agent-setup이 관리합니다) -->
## 너는 ${NAME}다 — 나의 AI 참모

- 정체성: ${NAME} (인생OS AI 참모)
- 호칭: 나를 **"${CALL}"**라고 부른다
- 톤: ${TONE}
- 역할: ${ROLE}
- 원칙: 결정은 내가 한다. ${NAME}는 배경·선택지·추천을 주고, 중요한 결정은 반드시 확인받는다.
<!-- LIFEOS-AGENT:END -->
BLOCK

if [ -f "$CLAUDE_MD" ] && grep -q "LIFEOS-AGENT:START" "$CLAUDE_MD"; then
    # 기존 블록만 교체 (나머지 보존) — 백업 먼저
    cp "$CLAUDE_MD" "$CLAUDE_MD.bak-$(date +%Y%m%d%H%M%S)"
    python3 - "$CLAUDE_MD" "$BLOCK_FILE" <<'PY'
import sys, re
md, blk = sys.argv[1], sys.argv[2]
content = open(md, encoding="utf-8").read()
block = open(blk, encoding="utf-8").read().strip()
new = re.sub(r"<!-- LIFEOS-AGENT:START.*?LIFEOS-AGENT:END -->", block, content, flags=re.DOTALL)
open(md, "w", encoding="utf-8").write(new)
PY
    echo "✓ 기존 AI 참모 설정을 교체했습니다 (백업 생성됨)."
else
    # 신규: CLAUDE.md 끝에 추가 (없으면 생성)
    { [ -f "$CLAUDE_MD" ] && cat "$CLAUDE_MD"; echo ""; cat "$BLOCK_FILE"; } > "$CLAUDE_MD.tmp" && mv "$CLAUDE_MD.tmp" "$CLAUDE_MD"
    echo "✓ AI 참모 설정을 추가했습니다."
fi
rm -f "$BLOCK_FILE"
echo "→ 다음 세션부터 ${NAME}로 동작합니다. (Claude Code 재시작 권장)"
```

---

## 📋 생성되는 CLAUDE.md 블록 예시

```markdown
<!-- LIFEOS-AGENT:START (이 블록은 /agent-setup이 관리합니다) -->
## 너는 폴라다 — 나의 AI 참모

- 정체성: 폴라 (인생OS AI 참모)
- 호칭: 나를 **"대표님"**라고 부른다
- 톤: 친근한 동료체
- 역할: 1인 사업 전략 + 콘텐츠 기획
- 원칙: 결정은 내가 한다. 폴라는 배경·선택지·추천을 주고, 중요한 결정은 반드시 확인받는다.
<!-- LIFEOS-AGENT:END -->
```

---

## ❓ FAQ

**Q: 업데이트하면 기존 참모 설정이 날아가나요?**
A: **아니요.** 기존 설정이 감지되면 자동으로 덮어쓰지 않고 "유지/수정/교체"를 물어봅니다. 기본값은 "유지"입니다. 교체 시에도 백업(`CLAUDE.md.bak-*`)을 남깁니다.

**Q: CLAUDE.md의 다른 내용도 바뀌나요?**
A: 아니요. `<!-- LIFEOS-AGENT:START -->`~`END` 블록만 갱신하고 나머지는 그대로 둡니다.

**Q: 나중에 톤만 바꾸고 싶어요.**
A: `/agent-setup` → "일부 수정" 선택 → 톤만 다시 답하면 됩니다.

**Q: 여러 참모를 두고 싶어요.**
A: 인생OS 기본은 1인 1참모입니다. 팀 단위 다중 에이전트는 `/agent-onboard`(팀 운영)에서 다룹니다.

---

## 📌 관련 스킬

- `/lifeOS-init` — 볼트 초기화 (CLAUDE.md 생성)
- `/today` · `/close-day` — 참모와 함께하는 일일 루틴
- `/control-tower` — 참모가 관리하는 대시보드

---

*GPTers 22기 부트캠프 W2/W4 핵심 실습 — AI 참모 설정 (비파괴적)*
*2026-06-09 폴라 작성*
