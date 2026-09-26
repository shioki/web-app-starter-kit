#!/usr/bin/env bash
# 3点セット (CKMS、requirements-to-spec-template、DADS) を新しい Web アプリのリポジトリに導入する。
#
#   bash scripts/bootstrap.sh <導入先>
#
# 導入先は Git リポジトリのルートを指定する。版は versions.env で固定し、CKMS と
# requirements-to-spec-template はその版を浅く clone して、配布元の導入スクリプトを実行する。
# 導入した版は導入先の .web-app-starter/versions.env に記録する。
set -eu

ROOT=$(cd "$(dirname "$0")/.." && pwd)
TARGET=""

usage() {
  sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'
}

die() {
  echo "エラー: $*" >&2
  exit 1
}

section() {
  printf '\n=== %s ===\n' "$*"
}

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    -*) echo "不明なオプション: $1" >&2; usage >&2; exit 2 ;;
    *)
      [ -z "$TARGET" ] || { echo "導入先は1つだけ指定してください" >&2; exit 2; }
      TARGET=$1
      ;;
  esac
  shift
done

[ -n "$TARGET" ] || { usage >&2; exit 2; }

# shellcheck source=../versions.env
. "$ROOT/versions.env"

STARTER_VERSION=$(git -C "$ROOT" describe --tags --always 2>/dev/null || echo unknown)

# 1. 前提の確認
command -v git >/dev/null 2>&1 || die "git が見つかりません"
[ -d "$TARGET" ] || die "導入先のディレクトリがありません: $TARGET"
TARGET=$(cd "$TARGET" && pwd)
[ "$TARGET" != "$ROOT" ] || die "このリポジトリ自身には導入できません"
[ -e "$TARGET/.git" ] || die "導入先が Git リポジトリのルートではありません: $TARGET (先に git init を実行してください)"

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

clone() {
  git -c advice.detachedHead=false clone --quiet --depth 1 --branch "$2" "$1" "$3"
}

echo "web-app-starter-kit $STARTER_VERSION"
echo "導入先: $TARGET"

# 2. CKMS。requirements-to-spec-template より先に実行する。
#    init.sh --with-agents-md は既存の AGENTS.md を上書きしないため、順番を入れ替えると
#    CKMS の AGENTS.md テンプレートが入らない。
section "CKMS $CKMS_REF"
clone "$CKMS_REPO" "$CKMS_REF" "$WORK/ckms"
bash "$WORK/ckms/skills/project-setup/scripts/init.sh" "$TARGET" --yes --with-agents-md

# 3. requirements-to-spec-template
section "requirements-to-spec-template $SPEC_REF"
clone "$SPEC_REPO" "$SPEC_REF" "$WORK/spec"
bash "$WORK/spec/scripts/install.sh" "$TARGET" --with-agents-md

# 4. DADS。コンポーネントは見本のコードなので取得せず、版と参照先を docs/design/README.md に書く
section "DADS $DADS_VERSION"
design="$TARGET/docs/design/README.md"
if [ -e "$design" ]; then
  echo "既存のため変更しない: docs/design/README.md"
else
  mkdir -p "$TARGET/docs/design"
  sed -e "s|{{DADS_VERSION}}|$DADS_VERSION|g" \
      -e "s|{{DADS_TOKENS_VERSION}}|$DADS_TOKENS_VERSION|g" \
      -e "s|{{DADS_TAILWIND_PLUGIN_VERSION}}|$DADS_TAILWIND_PLUGIN_VERSION|g" \
      "$ROOT/templates/design-README.md" > "$design"
  echo "作成: docs/design/README.md"
fi

# 5. AGENTS.md に3点セットの節を追記する。begin / end の節が既にあれば置き換える
section "AGENTS.md"
agents="$TARGET/AGENTS.md"
snippet="$ROOT/templates/AGENTS.starter.md"
begin="<!-- web-app-starter-kit:begin -->"
end="<!-- web-app-starter-kit:end -->"
if [ ! -e "$agents" ]; then
  printf '# AGENTS.md\n\n' > "$agents"
  cat "$snippet" >> "$agents"
  echo "作成: AGENTS.md"
elif grep -qxF "$begin" "$agents"; then
  tmp="$WORK/AGENTS.md"
  SNIPPET="$snippet" BEGIN_MARK="$begin" END_MARK="$end" awk '
    $0 == ENVIRON["BEGIN_MARK"] { while ((getline line < ENVIRON["SNIPPET"]) > 0) print line; skip = 1; next }
    $0 == ENVIRON["END_MARK"] { skip = 0; next }
    !skip { print }
  ' "$agents" > "$tmp"
  cat "$tmp" > "$agents"
  echo "3点セットの節を置き換え: AGENTS.md"
else
  printf '\n' >> "$agents"
  cat "$snippet" >> "$agents"
  echo "3点セットの節を追記: AGENTS.md"
fi

# 6. 版の記録と .gitignore
section "版の記録"
mkdir -p "$TARGET/.web-app-starter"
{
  echo "# web-app-starter-kit で導入した3点セットの版。更新の起点になるので手で書き換えない"
  echo "STARTER_KIT_VERSION=$STARTER_VERSION"
  grep -v '^#' "$ROOT/versions.env"
} > "$TARGET/.web-app-starter/versions.env"
echo "作成: .web-app-starter/versions.env"

# 初回導入では CKMS の退避は作られないが、更新で作られる退避を最初から Git に入れない
gitignore="$TARGET/.gitignore"
backup_pattern='.agents/skills.backup-*/'
if [ -f "$gitignore" ] && grep -qxF "$backup_pattern" "$gitignore"; then
  echo "既存のため変更しない: .gitignore"
else
  if [ -s "$gitignore" ] && [ -n "$(tail -c 1 "$gitignore")" ]; then
    printf '\n' >> "$gitignore"
  fi
  printf '# CKMS の更新時の退避 (web-app-starter-kit)\n%s\n' "$backup_pattern" >> "$gitignore"
  echo "追記: .gitignore ($backup_pattern)"
fi

# 8. 後片付けと案内。一時 clone は trap で削除する
section "導入しました"
cat <<EOF
導入したもの:
  - CKMS $CKMS_REF: .agents/skills/ (.claude/skills はそのリンク)、.cursor/、AGENTS.md、CLAUDE.md
  - AGENTS.md の3点セットの節 (web-app-starter-kit:begin / end)
  - requirements-to-spec-template $SPEC_REF: .agents/skills/ の要求仕様の3スキル、docs/requirements/
  - DADS $DADS_VERSION: docs/design/README.md (版、コンポーネント、アクセシビリティ方針)
  - 版の記録: .web-app-starter/versions.env

次にやること:
  1. 導入したファイルを確認し、コミットする
  2. /draft-spec で最初の要求仕様を作る
  3. docs/design/README.md の「要求仕様の制約条件に貼る行」を、要求仕様書の制約条件に貼る
EOF
