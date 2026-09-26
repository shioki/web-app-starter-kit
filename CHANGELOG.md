# Changelog

このプロジェクトの重要な変更はすべてこのファイルに記載します。

形式は [Keep a Changelog](https://keepachangelog.com/ja/1.0.0/) に基づき、このプロジェクトは [Semantic Versioning](https://semver.org/lang/ja/) に従います。

## [Unreleased]

### Added

- リポジトリの骨組み (`LICENSE` (MIT)、`.gitignore`、`.editorconfig`、`.markdownlint.jsonc`、`AGENTS.md`、`CLAUDE.md`、`CHANGELOG.md`) を追加
- 3点セットの版の一覧 `versions.env` を追加。CKMS v6.2.4、requirements-to-spec-template v0.4.0、DADS v2.18.0 (`@digital-go-jp/design-tokens` 2.0.1、`@digital-go-jp/tailwind-theme-plugin` 1.0.1)
- 導入スクリプト `scripts/bootstrap.sh` を追加。導入先の Git リポジトリに、CKMS (`init.sh --yes --with-agents-md`)、requirements-to-spec-template (`install.sh --with-agents-md`) の順で導入し、版を `.web-app-starter/versions.env` に記録する。導入先の `.gitignore` に CKMS の退避先 `.agents/skills.backup-*/` の除外を足す
- `.shellcheckrc` を追加。`scripts/` から `versions.env` を読み込む記述を shellcheck で追えるようにする
