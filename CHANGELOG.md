# Changelog

このプロジェクトの重要な変更はすべてこのファイルに記載します。

形式は [Keep a Changelog](https://keepachangelog.com/ja/1.0.0/) に基づき、このプロジェクトは [Semantic Versioning](https://semver.org/lang/ja/) に従います。

## [Unreleased]

### Changed

- `docs/handoff.md` の begin / end の記述を実態に合わせた。CKMS の `AGENTS.md` テンプレートには begin / end の目印が無いため、5.4 節と 7 章 P1-5・P3-1 の完了条件を2種類 (requirements-to-spec-template と web-app-starter-kit) に直した

## [0.3.0] - 2026-09-26

### Added

- 導入済みのプロジェクトを更新する `scripts/update.sh` を追加。導入先の `.web-app-starter/versions.env` と比べて版が変わった構成要素だけ、CKMS の `init.sh --yes --with-agents-md` と requirements-to-spec-template の `install.sh --with-agents-md` を新しい版で再実行する。`AGENTS.md` の3点セットの節、版の記録、`.gitignore` の退避先の除外を更新し、`validate.sh` で検証する。CKMS の退避先と、版を上げたあとに確かめることを表示する。版が下がる場合と、未導入の導入先では、何も変更せずに中止する
- `update.sh` が DADS の版の変更を `docs/design/README.md` に反映するようにした。版の表と制約条件に貼る行の版を書き換える。要求仕様の `制約-XX` は書き換えず、貼り直す行と、古い版を書いている仕様書を表示する
- CI に `update.sh` の結合試験 `scripts/test-update.sh` を追加。古い版で導入したプロジェクトに記録を足してから更新し、16スキル、記録、`AGENTS.md` の begin / end の節、`.gitignore` の除外、`validate.sh`、DADS の版の記載を確かめる。未導入のディレクトリで中止すること、同じ版なら何も変更しないこと、版が下がるなら中止することも確かめる
- `docs/updating.md` に、`update.sh` の使い方と処理、更新したあとに確かめること (退避先、`SKILL.md` の警告、`STANDARDS_TEMPLATE.md` と `paths`、`.cursor/agents/*.md`、DADS の制約行) を追加。README に更新手順を記載

### Changed

- `bootstrap.sh` と `update.sh` が共通で使う処理を `scripts/_common.sh` にまとめた
- `bootstrap.sh` を導入済みのプロジェクトに実行したとき、`update.sh` の実行方法を表示するようにした

## [0.2.0] - 2026-09-26

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

[Unreleased]: https://github.com/shioki/web-app-starter-kit/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/shioki/web-app-starter-kit/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/shioki/web-app-starter-kit/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/shioki/web-app-starter-kit/tree/v0.1.0
