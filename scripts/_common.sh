# shellcheck shell=bash
# bootstrap.sh と update.sh が共通で使う処理。単独では実行しない。
# 読み込む側で ROOT (このリポジトリのルート) と WORK (一時ディレクトリ) を決め、
# versions.env を読み込んでおく。

die() {
  echo "エラー: $*" >&2
  exit 1
}

section() {
  printf '\n=== %s ===\n' "$*"
}

# このリポジトリの版。タグから取得できなければ commit、Git でなければ unknown
starter_version() {
  git -C "$ROOT" describe --tags --always 2>/dev/null || echo unknown
}

clone() {
  git -c advice.detachedHead=false clone --quiet --depth 1 --branch "$2" "$1" "$3"
}

# 導入先の前提の確認。git があり、導入先が Git リポジトリのルートで、このリポジトリ自身でないこと。
# 確認した導入先の絶対パスを表示する
resolve_target() {
  command -v git >/dev/null 2>&1 || die "git が見つかりません"
  [ -d "$1" ] || die "導入先のディレクトリがありません: $1"
  resolved=$(cd "$1" && pwd)
  [ "$resolved" != "$ROOT" ] || die "このリポジトリ自身には導入できません"
  [ -e "$resolved/.git" ] || die "導入先が Git リポジトリのルートではありません: $resolved (先に git init を実行してください)"
  echo "$resolved"
}

# 版の記録 (KEY=VALUE) から値を読む。記録はシェルとして読み込まない
read_record() {
  sed -n "s/^$2=//p" "$1" | tail -n 1
}

# 版を比べて、1つ目が2つ目より古ければ <、新しければ >、同じなら = を表示する。
# 先頭の v を除いて数字と . だけでなければ比べられないので ? を表示する
version_compare() {
  awk -v a="$1" -v b="$2" '
    function plain(v) { sub(/^v/, "", v); return v }
    BEGIN {
      a = plain(a); b = plain(b)
      if (a !~ /^[0-9]+(\.[0-9]+)*$/ || b !~ /^[0-9]+(\.[0-9]+)*$/) { print "?"; exit }
      na = split(a, x, "."); nb = split(b, y, ".")
      n = na > nb ? na : nb
      for (i = 1; i <= n; i++) {
        xi = (i <= na) ? x[i] + 0 : 0
        yi = (i <= nb) ? y[i] + 0 : 0
        if (xi < yi) { print "<"; exit }
        if (xi > yi) { print ">"; exit }
      }
      print "="
    }'
}

# templates/design-README.md に versions.env の版を埋めて $1 に書く
render_design_readme() {
  mkdir -p "$(dirname "$1")"
  sed -e "s|{{DADS_VERSION}}|$DADS_VERSION|g" \
      -e "s|{{DADS_TOKENS_VERSION}}|$DADS_TOKENS_VERSION|g" \
      -e "s|{{DADS_TAILWIND_PLUGIN_VERSION}}|$DADS_TAILWIND_PLUGIN_VERSION|g" \
      "$ROOT/templates/design-README.md" > "$1"
}

# 導入先の AGENTS.md に3点セットの節を追記する。begin / end の節が既にあれば置き換える
apply_agents_section() {
  agents="$1/AGENTS.md"
  snippet="$ROOT/templates/AGENTS.starter.md"
  begin="<!-- web-app-starter-kit:begin -->"
  end="<!-- web-app-starter-kit:end -->"
  if [ ! -e "$agents" ]; then
    printf '# AGENTS.md\n\n' > "$agents"
    cat "$snippet" >> "$agents"
    echo "作成: AGENTS.md"
  elif grep -qxF "$begin" "$agents"; then
    SNIPPET="$snippet" BEGIN_MARK="$begin" END_MARK="$end" awk '
      $0 == ENVIRON["BEGIN_MARK"] { while ((getline line < ENVIRON["SNIPPET"]) > 0) print line; skip = 1; next }
      $0 == ENVIRON["END_MARK"] { skip = 0; next }
      !skip { print }
    ' "$agents" > "$WORK/AGENTS.md"
    cat "$WORK/AGENTS.md" > "$agents"
    echo "3点セットの節を置き換え: AGENTS.md"
  else
    printf '\n' >> "$agents"
    cat "$snippet" >> "$agents"
    echo "3点セットの節を追記: AGENTS.md"
  fi
}

# 導入先の .web-app-starter/versions.env に、このリポジトリの版と versions.env を書く
write_versions_record() {
  mkdir -p "$1/.web-app-starter"
  {
    echo "# web-app-starter-kit で導入した3点セットの版。更新の起点になるので手で書き換えない"
    echo "STARTER_KIT_VERSION=$(starter_version)"
    grep -v '^#' "$ROOT/versions.env"
  } > "$1/.web-app-starter/versions.env"
}

# 導入先の .gitignore に CKMS の更新時の退避 .agents/skills.backup-*/ の除外が無ければ足す
ensure_backup_ignored() {
  gitignore="$1/.gitignore"
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
}

# CKMS の validate.sh を導入先のルートで実行する。エラーがあれば中止する
validate_target() {
  if ! (cd "$1" && bash .agents/skills/project-setup/scripts/validate.sh); then
    die "CKMS の構造検証でエラーが見つかりました。上の表示を確認してください"
  fi
}
