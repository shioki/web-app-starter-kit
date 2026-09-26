# AGENTS.md

新規の Web アプリ開発プロジェクトへ3点セット (CKMS、requirements-to-spec-template、DADS) を導入するリポジトリそのものです。Cursor / Claude Code / Codex など、AGENTS.md を読むエージェント向けの規約をまとめます。構築の経緯と設計の推奨案は `docs/handoff.md` にあります。

## 配布物を複製しない

- 3点セットの中身 (スキル、テンプレート、DADS のコンポーネント) をこのリポジトリに置かない。`versions.env` で版を固定し、導入時に配布元から取得する
- CKMS と requirements-to-spec-template のリポジトリは、このリポジトリの作業では変更しない。必要な変更が見つかったら、内容をユーザーに報告する (Issue の下書きまで)
- フロントエンドの技術スタックは固定しない。導入スクリプトは既定で npm などのパッケージマネージャーを実行しない

## 版の一覧

- 3点セットの版は `versions.env` だけに書く。形式はシェルで読める `KEY=VALUE`
- 版を変えたら `CHANGELOG.md` の `[Unreleased]` に記録する
- `CKMS_REF` は v6.2.0 以上にする。v6.1.1 以前は、再実行で導入先の記録が消える

## 導入先に書くもの

- 導入先の `AGENTS.md` に追記する節は `<!-- web-app-starter-kit:begin -->` と `<!-- web-app-starter-kit:end -->` で囲む。begin / end のコメント行は置き換えの目印なので変えない
- CKMS と requirements-to-spec-template の begin / end で囲まれた範囲は変えない
- 導入した版は導入先の `.web-app-starter/versions.env` に記録する

## シェルスクリプト

- `set -eu` を使う
- `jq` / `python` / `node` に依存させない。POSIX シェルと `sed` / `awk` / `find` で書く
- `shellcheck` を通す

## 記述ルール

- 括弧は半角 `()` に統一する
- 「適切に」「なるべく」「可能な限り」などのあいまい語を使わない

## 作業の流れ

- コミットメッセージは Conventional Commits (`feat:` / `fix:` / `docs:` / `ci:` / `chore:`)。件名と本文は日本語
- `main` に直接コミットしない。作業ブランチから Pull Request を作り、CI が通ってからマージする
- push、Pull Request の作成、マージ、タグ、リリースは、ユーザーの指示を受けてから行う
- push 済みのタグは動かさない。リリース後に見つかった修正は、タグの後ろに積んで `[Unreleased]` に書く
