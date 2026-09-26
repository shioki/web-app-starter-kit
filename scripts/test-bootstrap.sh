#!/usr/bin/env bash
# bootstrap.sh の結合試験。一時ディレクトリに git init して導入し、配置と再実行の中止を確かめる。
#
#   bash scripts/test-bootstrap.sh
#
# CI の結合試験と同じ内容をローカルでも実行できる。ネットワークから CKMS と
# requirements-to-spec-template を取得する。
set -eu

ROOT=$(cd "$(dirname "$0")/.." && pwd)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

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

echo "=== Git リポジトリでない導入先は中止する ==="
mkdir "$WORK/not-git"
if bash "$ROOT/scripts/bootstrap.sh" "$WORK/not-git" >/dev/null 2>&1; then
  fail "Git リポジトリでない導入先で中止しなかった"
else
  pass "Git リポジトリでない導入先で中止した"
fi
check "何も作らない" test -z "$(ls -A "$WORK/not-git")"

echo "=== 初回導入 ==="
target="$WORK/app"
mkdir "$target"
git -C "$target" init -q
bash "$ROOT/scripts/bootstrap.sh" "$target"

echo "=== 配置の確認 ==="
equals ".agents/skills/ のスキルの数" 16 "$(find "$target/.agents/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
for skill in project-setup knowledge-management team-standards record-decision requirements-spec draft-spec review-spec; do
  check "スキル $skill" test -f "$target/.agents/skills/$skill/SKILL.md"
done
equals ".claude/skills のリンク先" "../.agents/skills" "$(readlink "$target/.claude/skills")"
check "docs/requirements/README.md" test -f "$target/docs/requirements/README.md"
check "docs/design/README.md" test -f "$target/docs/design/README.md"
check "docs/design/README.md に置き換え漏れが無い" sh -c "! grep -q '{{' '$target/docs/design/README.md'"
check ".web-app-starter/versions.env" test -f "$target/.web-app-starter/versions.env"
equals ".gitignore の退避先の除外" 1 "$(grep -cxF '.agents/skills.backup-*/' "$target/.gitignore")"
for mark in requirements-to-spec-template:begin requirements-to-spec-template:end web-app-starter-kit:begin web-app-starter-kit:end; do
  equals "AGENTS.md の $mark" 1 "$(grep -cF "<!-- $mark -->" "$target/AGENTS.md")"
done
equals "CLAUDE.md" "@AGENTS.md" "$(cat "$target/CLAUDE.md")"

echo "=== CKMS の構造検証 ==="
if (cd "$target" && bash .agents/skills/project-setup/scripts/validate.sh >/dev/null); then
  pass "validate.sh がエラー 0 件"
else
  fail "validate.sh がエラーを報告した"
fi

echo "=== 再実行は中止し、記録を残す ==="
sample="$target/.agents/skills/knowledge-management/references/decisions/2026-09-26-sample.md"
echo test > "$sample"
agents_before=$(cat "$target/AGENTS.md")
if bash "$ROOT/scripts/bootstrap.sh" "$target" >/dev/null 2>&1; then
  fail "導入済みの導入先で中止しなかった"
else
  pass "導入済みの導入先で中止した"
fi
check "decisions/ の既存ファイルが残る" test -f "$sample"
check "AGENTS.md が変わらない" test "$agents_before" = "$(cat "$target/AGENTS.md")"

echo ""
if [ "$FAILURES" -gt 0 ]; then
  echo "失敗: $FAILURES 件" >&2
  exit 1
fi
echo "すべて成功しました"
