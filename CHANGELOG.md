# Changelog

このプロジェクトの重要な変更はすべてこのファイルに記載します。

形式は [Keep a Changelog](https://keepachangelog.com/ja/1.0.0/) に基づき、このプロジェクトは [Semantic Versioning](https://semver.org/lang/ja/) に従います。

## [Unreleased]

### Added

- `bootstrap.sh --with-tailwind` を追加。導入先に `package.json` があれば、`@digital-go-jp/tailwind-theme-plugin` を `versions.env` の版に固定して `npm install -D --save-exact` で入れる。npm 以外のロックファイル (`pnpm-lock.yaml`、`yarn.lock`、`bun.lock`) があるときと、`package.json` が無いときは npm を実行せず、入れるコマンドを表示する。Tailwind CSS の設定ファイルは編集せず、v3 と v4 の読み込み方を表示する
- 版の上げ方を書いた `docs/updating.md` を追加。配布元の新しい版の確かめ方、`bootstrap.sh` やひな形も直す必要がある変更、`versions.env` を変えてからの試験、リリースの手順を書く

### Changed

- `bootstrap.sh` の最後の「次にやること」を詳しくした。`/draft-spec` と `/review-spec` の使い方、DADS の制約行を仕様書の制約条件に貼ること、`check_ids.py` での検査、プロジェクトの規約を `team-standards/references/STANDARDS_TEMPLATE.md` に書くことを表示する

## [0.1.0] - 2026-09-26

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

[Unreleased]: https://github.com/shioki/web-app-starter-kit/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/shioki/web-app-starter-kit/tree/v0.1.0
