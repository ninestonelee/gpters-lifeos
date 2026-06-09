---
name: essay-publish
description: 인생OS 에세이 자동발행(볼트 내부) - 데일리 에세이를 수집해 월별 모음집 + 명장면 인덱스로 정리. 외부 발송 없음. 주 1회 또는 월말 실행.
---

# ✍️ 에세이 발행 스킬

> **인생OS 17개 스킬 중 #15** (Tier 5: 기억 보존)
> **주 1회 또는 월말** 실행

매일 `/close-day`에서 쓴 에세이를 모아 **월별 모음집**과 **명장면 인덱스**로 정리합니다. 4주 성장의 기록을 한눈에 볼 수 있게 만듭니다.

> 🔒 **볼트 내부 발행만** — 외부 블로그/SNS로 자동 발송하지 않습니다. (안전)

---

## 사용 방법

```
/essay-publish              # 이번 달 에세이 발행
/essay-publish 2026-05      # 특정 월 지정
```

→ 다음을 자동 수행:
1. 데일리 노트 + 에세이 파일에서 에세이 본문 수집
2. `08_chronicle/essays/essays_YYYY-MM.md` 월별 모음집 생성
3. `08_chronicle/essays/에세이_인덱스.md` 명장면 인덱스 갱신 (날짜 + 첫 문장 + 링크)
4. Obsidian에서 인덱스 열기

---

## 실행 로직

```bash
#!/bin/bash

# 볼트 자동 탐색
if [ -n "$LIFEOS_VAULT" ] && [ -d "$LIFEOS_VAULT" ]; then
    VAULT="$LIFEOS_VAULT"
else
    VAULT=$(find "$HOME" -maxdepth 1 -type d -name "lifeOS_*" 2>/dev/null | head -1)
    [ -z "$VAULT" ] && { echo "❌ 볼트 없음 — /lifeOS-init 먼저"; exit 1; }
fi
USER_NAME=$(basename "$VAULT" | sed 's/lifeOS_//')

DAILY_DIR=$(find "$VAULT" -maxdepth 1 -type d \( -name "01_daily" -o -name "01_데일리" \) | head -1)
[ -z "$DAILY_DIR" ] && DAILY_DIR="$VAULT/01_daily"
CHRON_DIR=$(find "$VAULT" -maxdepth 1 -type d \( -name "08_chronicle" -o -name "08_연대기" \) | head -1)
[ -z "$CHRON_DIR" ] && CHRON_DIR="$VAULT/08_chronicle"
ESSAY_DIR="$CHRON_DIR/essays"; mkdir -p "$ESSAY_DIR"

TARGET="${1:-$(date +%Y-%m)}"
COLLECTION="$ESSAY_DIR/essays_${TARGET}.md"
INDEX="$ESSAY_DIR/에세이_인덱스.md"

echo "✍️ ${USER_NAME}님 에세이 발행 — $TARGET"

# ── 에세이 추출 함수 ──
# 데일리 노트에서 "## 에세이" 또는 "## 회고" 이후 ~ 명장면/깨달음 본문 추출
# (대상: 01_daily 루트 + 아카이브 하위폴더 + 기존 에세이 .md)
TMP=$(mktemp)
COUNT=0

# 1) 데일리 노트의 에세이/명장면/깨달음 섹션
for f in $(find "$DAILY_DIR" -name "${TARGET}-*.md" 2>/dev/null | sort); do
    d=$(basename "$f" .md)
    # 에세이 관련 섹션 추출 (## 에세이 / ## 명장면 / ## 깨달음 / ## 회고 이후)
    body=$(awk '/^## (에세이|명장면|깨달음|회고)/{f=1} f&&/^## /&&!/에세이|명장면|깨달음|회고/{f=0} f' "$f" 2>/dev/null | grep -vE "^## |^---|^>|^\s*$" | head -20)
    if [ -n "$body" ]; then
        echo "## $d" >> "$TMP"
        echo "" >> "$TMP"
        echo "$body" >> "$TMP"
        echo "" >> "$TMP"
        echo "[[$d|→ 원본 데일리]]" >> "$TMP"
        echo "" >> "$TMP"
        echo "---" >> "$TMP"
        echo "" >> "$TMP"
        COUNT=$((COUNT+1))
    fi
done

# 2) 월별 모음집 작성
if [ "$COUNT" -gt 0 ]; then
    {
        echo "# ✍️ ${USER_NAME}의 에세이 모음 — $TARGET"
        echo ""
        echo "> ${COUNT}편 · 발행 $(date "+%Y-%m-%d %H:%M") · \`/essay-publish\`"
        echo ""
        echo "---"
        echo ""
        cat "$TMP"
    } > "$COLLECTION"
    echo "✓ 월별 모음집: $COLLECTION (${COUNT}편)"
else
    echo "ℹ️ $TARGET 에세이를 찾지 못했습니다 (데일리 ## 에세이/명장면/깨달음 섹션 확인)."
fi
rm -f "$TMP"

# ── 3) 명장면 인덱스 갱신 (전체 월 모음집 스캔) ──
{
    echo "# 📖 ${USER_NAME}의 에세이 인덱스"
    echo ""
    echo "> 갱신 $(date "+%Y-%m-%d %H:%M") · \`/essay-publish\` · 명장면(첫 문장) 한눈에"
    echo ""
    for col in $(find "$ESSAY_DIR" -name "essays_*.md" 2>/dev/null | sort -r); do
        m=$(basename "$col" .md | sed 's/essays_//')
        echo "## $m"
        echo ""
        # 각 ## YYYY-MM-DD 항목의 첫 본문 줄(명장면) 추출
        awk '
            /^## 20[0-9][0-9]-/{ if(date){print "- [["col"|"date"]] — "first}; date=$2; first=""; next }
            date && first=="" && NF>0 && $0!~/^(---|\[\[|>|#)/ { first=substr($0,1,60) }
            END{ if(date) print "- [["col"|"date"]] — "first }
        ' col="$(basename "$col" .md)" "$col" 2>/dev/null
        echo ""
    done
} > "$INDEX"
echo "✓ 명장면 인덱스: $INDEX"

command -v open >/dev/null && open "$INDEX" 2>/dev/null
```

---

## 📋 발행 결과 구조

```
08_chronicle/essays/
├── 에세이_인덱스.md       ← 명장면(첫 문장) 한눈에 + 링크
├── essays_2026-06.md      ← 6월 에세이 모음집
└── essays_2026-05.md      ← 5월 에세이 모음집
```

인덱스 예시:
```markdown
# 📖 홍길동의 에세이 인덱스

## 2026-06
- [[essays_2026-06|2026-06-09]] — 오늘 깨달은 것은 북극성이 없으면 선택이 무겁다는 것
- [[essays_2026-06|2026-06-08]] — 도구가 동료가 되려면 기억을 쥐어줘야 한다
```

---

## ❓ FAQ

**Q: 외부 블로그(티스토리/velog)로 발행되나요?**
A: 아니요. **볼트 내부에만** 정리합니다. 외부 발송은 의도적으로 제외했습니다(사고 방지). 외부 발행은 별도 도구로 직접 하세요.

**Q: 에세이를 어디서 가져오나요?**
A: 데일리 노트의 `## 에세이` / `## 명장면` / `## 깨달음` / `## 회고` 섹션입니다. `/close-day`에서 이 섹션을 채우면 자동 수집됩니다.

**Q: 명장면 인덱스의 "첫 문장"이 이상해요.**
A: 각 날짜 섹션의 첫 본문 줄을 명장면으로 씁니다. 데일리 회고/에세이 첫 줄을 핵심 한 문장으로 쓰면 깔끔해집니다.

---

## 📌 관련 스킬

- `/close-day` — 일일 에세이 작성 (발행의 원천)
- `/monthly-archive` — 월간 데일리 아카이빙
- `/control-tower` — 최근 에세이를 대시보드에 표시

---

*GPTers 22기 부트캠프 W3 핵심 실습 — 에세이 발행*
*2026-06-09 폴라 작성*
