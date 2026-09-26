#!/usr/bin/env bash
# bootstrap.sh で導入したプロジェクトを、このリポジトリの versions.env の版に更新する。
#
#   bash scripts/update.sh <導入先>
#
# 導入先の .web-app-starter/versions.env と比べて、版が変わった構成要素だけを更新する。
# CKMS と requirements-to-spec-template は、新しい版を浅く clone して配布元の導入スクリプトを
# 再実行する。CKMS の再実行は置き換える前のスキルを .agents/skills.backup-*/ に退避する。
# 版が1つでも下がる場合は、何も変更せずに中止する。
set -eu

ROOT=$(cd "$(dirname "$0")/.." && pwd)
TARGET=""

usage() {
  sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'
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
# shellcheck source=_common.sh
. "$ROOT/scripts/_common.sh"

# 1. 前提の確認と、変わる版の表示
TARGET=$(resolve_target "$TARGET")
record="$TARGET/.web-app-starter/versions.env"
if [ ! -e "$record" ]; then
  echo "エラー: 未導入です ($record がありません)。何も変更せずに中止しました" >&2
  echo "初回の導入は bootstrap.sh で行います:" >&2
  echo "  bash $ROOT/scripts/bootstrap.sh $TARGET" >&2
  exit 1
fi

echo "web-app-starter-kit $(starter_version)"
echo "導入先: $TARGET"

section "変わる版"
ckms_changed=false
spec_changed=false
dads_changed=false
downgrades=""
for key in CKMS_REPO CKMS_REF SPEC_REPO SPEC_REF DADS_VERSION DADS_TOKENS_VERSION DADS_TAILWIND_PLUGIN_VERSION; do
  old=$(read_record "$record" "$key")
  new=$(eval "echo \"\${$key}\"")
  [ "$old" != "$new" ] || continue
  echo "  $key: ${old:-(記録なし)} → $new"
  case "$key" in
    *_REPO) ;;
    *)
      if [ "$(version_compare "$new" "$old")" = "<" ]; then
        downgrades="$downgrades $key"
      fi
      ;;
  esac
  case "$key" in
    CKMS_*) ckms_changed=true ;;
    SPEC_*) spec_changed=true ;;
    DADS_*) dads_changed=true ;;
  esac
done

old_starter=$(read_record "$record" STARTER_KIT_VERSION)
new_starter=$(starter_version)
starter_changed=false
if [ "$old_starter" != "$new_starter" ]; then
  starter_changed=true
  echo "  STARTER_KIT_VERSION: ${old_starter:-(記録なし)} → $new_starter"
  if [ "$(version_compare "$new_starter" "$old_starter")" = "<" ]; then
    downgrades="$downgrades STARTER_KIT_VERSION"
  fi
fi

if [ -n "$downgrades" ]; then
  echo "エラー: 版が下がります (${downgrades# })。何も変更せずに中止しました" >&2
  echo "導入先はこの web-app-starter-kit より新しい版で導入されています。新しい web-app-starter-kit を取得して実行してください" >&2
  exit 1
fi

if [ "$ckms_changed" = false ] && [ "$spec_changed" = false ] && [ "$dads_changed" = false ] && [ "$starter_changed" = false ]; then
  echo "  (なし)"
  echo ""
  echo "導入先はこの web-app-starter-kit と同じ版です。何も変更しませんでした"
  exit 0
fi

# CKMS v6.1.1 以前の init.sh は、再実行で .agents/skills を作り直して記録を消す
if [ "$ckms_changed" = true ] && [ "$(version_compare "$CKMS_REF" v6.2.0)" = "<" ]; then
  die "CKMS_REF ($CKMS_REF) が v6.2.0 より古いため中止しました。v6.1.1 以前の再実行は導入先の記録を消します"
fi

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

# 2. CKMS。導入先の中の init.sh は導入先自身に向けて実行できないので、clone したほうを使う。
#    退避を残すため --no-backup は渡さない
new_backups=""
if [ "$ckms_changed" = true ]; then
  section "CKMS $CKMS_REF"
  clone "$CKMS_REPO" "$CKMS_REF" "$WORK/ckms"
  ls -d "$TARGET"/.agents/skills.backup-* > "$WORK/backups-before" 2>/dev/null || :
  bash "$WORK/ckms/skills/project-setup/scripts/init.sh" "$TARGET" --yes --with-agents-md
  ls -d "$TARGET"/.agents/skills.backup-* > "$WORK/backups-after" 2>/dev/null || :
  new_backups=$(grep -vxF -f "$WORK/backups-before" "$WORK/backups-after" || :)
fi

# 3. requirements-to-spec-template。自分の3スキルと AGENTS.md の節だけを置き換える
if [ "$spec_changed" = true ]; then
  section "requirements-to-spec-template $SPEC_REF"
  clone "$SPEC_REPO" "$SPEC_REF" "$WORK/spec"
  bash "$WORK/spec/scripts/install.sh" "$TARGET" --with-agents-md
fi

# 5. AGENTS.md の3点セットの節と、版の記録
section "AGENTS.md と版の記録"
apply_agents_section "$TARGET"
write_versions_record "$TARGET"
echo "更新: .web-app-starter/versions.env"
# v0.1.0 より前の手順で導入したプロジェクトには除外が無いことがある
ensure_backup_ignored "$TARGET"

# 6. 検証
section "検証"
validate_target "$TARGET"

# 7. 後片付けと案内。一時 clone は trap で削除する
section "更新しました"
echo "更新したもの:"
[ "$ckms_changed" = false ] || echo "  - CKMS: $CKMS_REF"
[ "$spec_changed" = false ] || echo "  - requirements-to-spec-template: $SPEC_REF"
echo "  - AGENTS.md の3点セットの節と .web-app-starter/versions.env: web-app-starter-kit $new_starter"
echo ""
echo "次にやること:"
echo "  - 変更を確認し、コミットする"
echo "      cd $TARGET && git status"
if [ "$ckms_changed" = true ]; then
  if [ -n "$new_backups" ]; then
    echo "  - CKMS が置き換える前のスキルを次に退避した。確認が済んだら削除してよい (.gitignore で Git から外している)"
    printf '%s\n' "$new_backups" | sed "s|^$TARGET/|      |"
  fi
  cat <<'EOF'
  - 「SKILL.md は配布元と異なります」の警告は、版を上げて SKILL.md が変わったスキルで出る。
    SKILL.md を書き換えていなければ無視してよい
  - プロジェクトの規約は .agents/skills/team-standards/references/STANDARDS_TEMPLATE.md に書く。
    team-standards の SKILL.md の paths を変えていた場合は、退避先の SKILL.md を見て入れ直す
  - .cursor/agents/*.md は配布元の内容で上書きした。書き換えていた場合は、Git の差分で確かめる
EOF
fi
