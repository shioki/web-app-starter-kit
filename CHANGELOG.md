# Changelog

このプロジェクトの重要な変更はすべてこのファイルに記載します。

形式は [Keep a Changelog](https://keepachangelog.com/ja/1.0.0/) に基づき、このプロジェクトは [Semantic Versioning](https://semver.org/lang/ja/) に従います。

## [Unreleased]

### Added

- リポジトリの骨組み (`LICENSE` (MIT)、`.gitignore`、`.editorconfig`、`.markdownlint.jsonc`、`AGENTS.md`、`CLAUDE.md`、`CHANGELOG.md`) を追加
- 3点セットの版の一覧 `versions.env` を追加。CKMS v6.2.4、requirements-to-spec-template v0.4.0、DADS v2.18.0 (`@digital-go-jp/design-tokens` 2.0.1、`@digital-go-jp/tailwind-theme-plugin` 1.0.1)
- 導入スクリプト `scripts/bootstrap.sh` を追加。導入先の Git リポジトリに、CKMS (`init.sh --yes --with-agents-md`)、requirements-to-spec-template (`install.sh --with-agents-md`) の順で導入し、版を `.web-app-starter/versions.env` に記録する。導入先の `.gitignore` に CKMS の退避先 `.agents/skills.backup-*/` の除外を足す
- `.shellcheckrc` を追加。`scripts/` から `versions.env` を読み込む記述を shellcheck で追えるようにする
- `bootstrap.sh` が導入先に `docs/design/README.md` を作るようにした。DADS のサイトとパッケージの版、要求仕様の制約条件に貼る行、コンポーネント一覧と見本のコード、アクセシビリティ方針への参照を書く。ひな形は `templates/design-README.md`
- `bootstrap.sh` が導入先の `AGENTS.md` に3点セットの節 (`templates/AGENTS.starter.md`) を追記するようにした。DADS の版に従うこと、アクセシビリティの目標、`/record-decision` と `未解決-XX` の結び付け、プロジェクトの規約の置き場所を書く。節は `<!-- web-app-starter-kit:begin -->` と `<!-- web-app-starter-kit:end -->` で囲み、既にあれば置き換える
- `bootstrap.sh` の最後に CKMS の `validate.sh` を導入先で実行し、結果を表示するようにした。エラーがあれば 0 以外で終わる
- `bootstrap.sh` は導入先に `.web-app-starter/versions.env` があれば、導入済みとして何も変更せずに中止するようにした
- CI (`.github/workflows/ci.yml`) を追加。`shellcheck`、`markdownlint-cli2`、`lychee`、結合試験 `scripts/test-bootstrap.sh` (一時ディレクトリに `git init` して導入し、配置、`validate.sh`、再実行の中止を確かめる) を実行する
- README に、前提 (`git`、`bash`)、導入手順、導入されるもの、Windows の扱い (WSL か Git Bash) を記載
