# web-app-starter-kit

新規の Web アプリ開発プロジェクトへ、次の 3 つ (以下「3点セット」) を一括で導入するためのリポジトリです。

| 構成要素 | 役割 | 取得元 |
| --- | --- | --- |
| Cursor Knowledge Management System (CKMS) | 技術判断・パターン・デバッグ記録などの知識管理 | <https://github.com/shioki/Cursor-Knowledge-Management-System> |
| requirements-to-spec-template | Web アプリの要求仕様 | <https://github.com/shioki/requirements-to-spec-template> |
| デジタル庁デザインシステム (DADS) | 画面設計とアクセシビリティの基準 | <https://design.digital.go.jp/dads/> |

このリポジトリは 3 つの中身を持ちません。どの版を組み合わせるかを決め、その版を配布元から取得して配置することだけを担当します。フロントエンドの技術スタックは固定しません。

## 前提

- `git` と `bash` があること
- 導入先が Git リポジトリのルートであること (新しいリポジトリなら `git init` 済み)
- 導入中に GitHub から CKMS と requirements-to-spec-template を取得するため、ネットワークにつながること

## 導入手順

新しい Web アプリのリポジトリを作ったあと、このリポジトリを版 (タグ) を固定して取得し、導入スクリプトを実行します。

```bash
git clone --depth 1 --branch v0.2.0 https://github.com/shioki/web-app-starter-kit.git /tmp/web-app-starter-kit
bash /tmp/web-app-starter-kit/scripts/bootstrap.sh /path/to/new-web-app
```

`bootstrap.sh` は次の順で導入します。

1. 導入先がディレクトリで、Git リポジトリのルートであることを確認する。導入済み (`.web-app-starter/versions.env` がある) なら、何も変更せずに中止する
2. CKMS を固定した版で取得し、`init.sh <導入先> --yes --with-agents-md` を実行する
3. requirements-to-spec-template を固定した版で取得し、`install.sh <導入先> --with-agents-md` を実行する
4. DADS の版と参照先を書いた `docs/design/README.md` を作る
5. `AGENTS.md` に3点セットの節を追記する
6. 導入した版を `.web-app-starter/versions.env` に記録し、`.gitignore` に `.agents/skills.backup-*/` を足す
7. CKMS の `validate.sh` で構造を検証する
8. 一時的に取得したものを削除し、導入したものと次にやることを表示する

導入が終わったら、導入先で変更を確認してコミットします。

### Tailwind CSS を使う場合

`--with-tailwind` を付けると、DADS の Tailwind CSS テーマプラグイン (`@digital-go-jp/tailwind-theme-plugin`) を `versions.env` の版に固定して入れます。

```bash
bash /tmp/web-app-starter-kit/scripts/bootstrap.sh /path/to/new-web-app --with-tailwind
```

- 導入先に `package.json` があれば `npm install -D --save-exact` を実行する。`package.json` が無ければ、npm は実行せずにコマンドを表示する
- `pnpm-lock.yaml`、`yarn.lock`、`bun.lock` (`bun.lockb`) があれば、npm は実行せず、そのパッケージマネージャーで入れるコマンドを表示する
- Tailwind CSS の設定ファイルは編集しない。v3 は `tailwind.config.js` の `plugins`、v4 は CSS の `@import` で読み込む書き方を表示する

`--with-tailwind` を付けなければ、npm などのパッケージマネージャーは実行しません。

## 導入されるもの

| 場所 | 内容 | 配布元 |
| --- | --- | --- |
| `.agents/skills/` | 知識管理の13スキルと要求仕様の3スキル (計16) | CKMS、requirements-to-spec-template |
| `.claude/skills` | `.agents/skills` へのシンボリックリンク (Claude Code 用) | CKMS |
| `.cursor/` | hooks と subagent | CKMS |
| `AGENTS.md`、`CLAUDE.md` | エージェント向けの規約。`AGENTS.md` には要求仕様の節と3点セットの節が入る | CKMS、requirements-to-spec-template、このリポジトリ |
| `docs/requirements/` | 要求仕様書の置き場所と一覧 | requirements-to-spec-template |
| `docs/design/README.md` | 準拠する DADS の版、要求仕様の制約条件に貼る行、コンポーネントとアクセシビリティ方針への参照 | このリポジトリ |
| `.web-app-starter/versions.env` | 導入した版の記録 | このリポジトリ |

DADS のコンポーネントは見本のコードなので、導入しません。`docs/design/README.md` の参照先から、必要なものをプロジェクトに取り込みます。npm パッケージ (`@digital-go-jp/design-tokens` など) も導入しません。使う版は `docs/design/README.md` に書いてあります。

## 版

組み合わせる版は [versions.env](versions.env) で固定しています。版の変更は [CHANGELOG.md](CHANGELOG.md) に記録します。

## Windows

`bootstrap.sh` は bash で動きます。CKMS には PowerShell 版の `init.ps1` がありますが、requirements-to-spec-template には PowerShell 版がありません。WSL か Git Bash で実行してください。

## 導入済みのプロジェクトの更新

`bootstrap.sh` は初回導入だけを担当し、導入済みのプロジェクトでは中止します。更新用の `scripts/update.sh` は今後の版で追加します。

3点セットの版を上げてこのリポジトリをリリースする手順は [docs/updating.md](docs/updating.md) にあります。

## 開発

- エージェント向けの規約は [AGENTS.md](AGENTS.md) にあります
- 導入の結合試験は `bash scripts/test-bootstrap.sh` でローカルでも実行できます (CI と同じ内容)
- 構築の引き継ぎは [docs/handoff.md](docs/handoff.md) にあります

## ライセンス

[MIT](LICENSE)
