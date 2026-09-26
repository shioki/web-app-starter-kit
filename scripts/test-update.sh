#!/usr/bin/env bash
# update.sh の結合試験。古い版で導入したプロジェクトを update.sh で更新し、スキル、記録、
# AGENTS.md の節、.gitignore、DADS の版の記載を確かめる。未導入のディレクトリ、同じ版、
# 版が下がる場合の動きも確かめる。
#
#   bash scripts/test-update.sh
#
# CI の結合試験と同じ内容をローカルでも実行できる。ネットワークから CKMS と
# requirements-to-spec-template を取得する。
set -eu

ROOT=$(cd "$(dirname "$0")/.." && pwd)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

# shellcheck source=../versions.env
. "$ROOT/versions.env"

FAILURES=0

pass() {
  echo "  [OK] $*"
}

fail() {
  echo "  [NG] $*" >&2
  FAILURES=$((FAILURES + 1))
}

check() {
  label=$1
  shift
  if "$@"; then pass "$label"; else fail "$label"; fi
}

equals() {
  label=$1
  expected=$2
  actual=$3
  if [ "$actual" = "$expected" ]; then
    pass "$label: $actual"
  else
    fail "$label: 期待 $expected、実際 $actual"
  fi
}

snapshot() {
  (cd "$1" && find . -path ./.git -prune -o -type f -print | LC_ALL=C sort | while IFS= read -r f; do cksum "$f"; done)
}

echo "=== 未導入のディレクトリは中止する ==="
mkdir "$WORK/not-installed"
git -C "$WORK/not-installed" init -q
if bash "$ROOT/scripts/update.sh" "$WORK/not-installed" > "$WORK/not-installed.log" 2>&1; then
  fail "未導入のディレクトリで中止しなかった"
else
  pass "未導入のディレクトリで中止した"
fi
check "bootstrap.sh を案内する" grep -qF "scripts/bootstrap.sh" "$WORK/not-installed.log"
check "何も作らない" test "$(ls -A "$WORK/not-installed")" = ".git"

echo "=== 古い版で導入する ==="
# 古い版の web-app-starter-kit を作る。CKMS と DADS は1つ前の版にする。
# requirements-to-spec-template は install.sh が v0.4.0 からなので、記録だけを下げる
old_kit="$WORK/old-kit"
mkdir "$old_kit"
cp -R "$ROOT/scripts" "$ROOT/templates" "$ROOT/versions.env" "$old_kit/"
sed -e 's/^CKMS_REF=.*/CKMS_REF=v6.2.3/' \
    -e 's/^DADS_VERSION=.*/DADS_VERSION=v2.17.0/' \
    -e 's/^DADS_TOKENS_VERSION=.*/DADS_TOKENS_VERSION=2.0.0/' \
    -e 's/^DADS_TAILWIND_PLUGIN_VERSION=.*/DADS_TAILWIND_PLUGIN_VERSION=1.0.0/' \
    "$ROOT/versions.env" > "$old_kit/versions.env"
target="$WORK/app"
mkdir "$target"
git -C "$target" init -q
bash "$old_kit/scripts/bootstrap.sh" "$target" > "$WORK/bootstrap.log"
record="$target/.web-app-starter/versions.env"
sed 's/^SPEC_REF=.*/SPEC_REF=v0.3.0/' "$record" > "$WORK/record" && cat "$WORK/record" > "$record"

# 利用者の記録と仕様書を足す
sample="$target/.agents/skills/knowledge-management/references/decisions/2026-09-26-sample.md"
echo test > "$sample"
spec="$target/docs/requirements/sample.md"
printf '# sample\n\n| 制約-01 | 画面はデジタル庁デザインシステム(DADS) v2.17.0 に準拠する |\n' > "$spec"
spec_before=$(cksum < "$spec")

echo "=== update.sh で更新する ==="
bash "$ROOT/scripts/update.sh" "$target" > "$WORK/update.log"
check "変わる版に CKMS_REF を表示する" grep -qF "CKMS_REF: v6.2.3 → $CKMS_REF" "$WORK/update.log"
check "変わる版に SPEC_REF を表示する" grep -qF "SPEC_REF: v0.3.0 → $SPEC_REF" "$WORK/update.log"

echo "=== 更新後の確認 ==="
equals ".agents/skills/ のスキルの数" 16 "$(find "$target/.agents/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
check "decisions/ の既存ファイルが残る" test -f "$sample"
for mark in requirements-to-spec-template:begin requirements-to-spec-template:end web-app-starter-kit:begin web-app-starter-kit:end; do
  equals "AGENTS.md の $mark" 1 "$(grep -cF "<!-- $mark -->" "$target/AGENTS.md")"
done
equals ".gitignore の退避先の除外" 1 "$(grep -cxF '.agents/skills.backup-*/' "$target/.gitignore")"
equals "CKMS の退避先" 1 "$(find "$target/.agents" -mindepth 1 -maxdepth 1 -name 'skills.backup-*' | wc -l | tr -d ' ')"
check "退避先を案内する" grep -qF ".agents/skills.backup-" "$WORK/update.log"
if (cd "$target" && bash .agents/skills/project-setup/scripts/validate.sh >/dev/null); then
  pass "validate.sh がエラー 0 件"
else
  fail "validate.sh がエラーを報告した"
fi
equals "記録の CKMS_REF" "$CKMS_REF" "$(sed -n 's/^CKMS_REF=//p' "$record")"
equals "記録の SPEC_REF" "$SPEC_REF" "$(sed -n 's/^SPEC_REF=//p' "$record")"
equals "記録の DADS_VERSION" "$DADS_VERSION" "$(sed -n 's/^DADS_VERSION=//p' "$record")"

echo "=== DADS の版の記載 ==="
design="$target/docs/design/README.md"
check "サイトの版が新しい" grep -qF "| DADS (サイト) | $DADS_VERSION |" "$design"
check "制約行が新しい版" grep -qF "(DADS) $DADS_VERSION に準拠する。デザイントークンは \`@digital-go-jp/design-tokens\` $DADS_TOKENS_VERSION を使う" "$design"
check "プラグインの制約行が新しい版" grep -qF "\`@digital-go-jp/tailwind-theme-plugin\` $DADS_TAILWIND_PLUGIN_VERSION を使う" "$design"
check "古い版が残らない" sh -c "! grep -qE 'v2\\.17\\.0|2\\.0\\.0|1\\.0\\.0' '$design'"
check "要求仕様の制約-XX は書き換えない" test "$spec_before" = "$(cksum < "$spec")"
check "古い版を書いている仕様書を案内する" grep -qF "docs/requirements/sample.md" "$WORK/update.log"

echo "=== 同じ版なら何も変更しない ==="
before=$(snapshot "$target")
if bash "$ROOT/scripts/update.sh" "$target" > "$WORK/same.log" 2>&1; then
  pass "0 で終わる"
else
  fail "0 以外で終わった"
fi
check "導入先が変わらない" test "$before" = "$(snapshot "$target")"

echo "=== 版が下がるなら中止する ==="
sed "s/^CKMS_REF=.*/CKMS_REF=v99.0.0/" "$record" > "$WORK/record" && cat "$WORK/record" > "$record"
before=$(snapshot "$target")
if bash "$ROOT/scripts/update.sh" "$target" > "$WORK/down.log" 2>&1; then
  fail "版が下がるのに中止しなかった"
else
  pass "版が下がるので中止した"
fi
check "導入先が変わらない" test "$before" = "$(snapshot "$target")"

echo ""
if [ "$FAILURES" -gt 0 ]; then
  echo "失敗: $FAILURES 件" >&2
  exit 1
fi
echo "すべて成功しました"
