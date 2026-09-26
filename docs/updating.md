# 更新と版の上げ方

3点セットの版は [versions.env](../versions.env) だけで固定しています。この文書には次の2つを書きます。

- [導入済みのプロジェクトを更新する](#導入済みのプロジェクトを更新する): `scripts/update.sh` で、導入先を web-app-starter-kit の新しい版に合わせる
- [このリポジトリの版を上げる](#このリポジトリの版を上げる): `versions.env` の版を上げて、web-app-starter-kit の新しい版をリリースする

## 導入済みのプロジェクトを更新する

`bootstrap.sh` は初回導入だけを担当し、導入済みのプロジェクトでは中止します。更新には `update.sh` を使います。新しい版の web-app-starter-kit を取得して実行します。

```bash
git clone --depth 1 --branch vX.Y.Z https://github.com/shioki/web-app-starter-kit.git /tmp/web-app-starter-kit
bash /tmp/web-app-starter-kit/scripts/update.sh /path/to/web-app
```

導入のときに取得した `/tmp/web-app-starter-kit` が残っていると `git clone` が失敗するので、先に削除します。

### update.sh の処理

1. 導入先に `.web-app-starter/versions.env` が無ければ、未導入として中止し、`bootstrap.sh` を案内する。あれば、この web-app-starter-kit の `versions.env` と比べて変わる版を表示する
    - 変わる版が無ければ、何も変更せずに終わる
    - 版が1つでも下がる (導入先が新しい web-app-starter-kit で導入されている) なら、何も変更せずに中止する
2. CKMS の版が変わったら、新しい版を取得し、`init.sh <導入先> --yes --with-agents-md` を実行する。置き換える前のスキルは `.agents/skills.backup-YYYYmmdd-HHMMSS/` に退避される
3. requirements-to-spec-template の版が変わったら、新しい版を取得し、`install.sh <導入先> --with-agents-md` を実行する。自分の3スキルと `AGENTS.md` の節だけが置き換わる
4. DADS の版が変わったら、`docs/design/README.md` の版の記載を書き換える。要求仕様の `制約-XX` は書き換えない
5. `AGENTS.md` の3点セットの節を置き換え、`.web-app-starter/versions.env` を書き換える。`.gitignore` に `.agents/skills.backup-*/` が無ければ足す
6. CKMS の `validate.sh` で構造を検証する
7. 一時的に取得したものを削除し、更新したものと次にやることを表示する

版が変わらなかった構成要素は再実行しません。web-app-starter-kit 自身の版だけが違う場合は、5 から 7 だけを行います。

### 更新したあとに確かめること

- **変更の確認とコミット**: 導入先で `git status` と `git diff` を見てからコミットする
- **CKMS の退避先**: `.agents/skills.backup-YYYYmmdd-HHMMSS/` は、確認が済んだら削除してよい。`.gitignore` で Git から外している
- **「SKILL.md は配布元と異なります」の警告**: 版を上げると、`SKILL.md` が変わったスキルで出る。`SKILL.md` を書き換えていなければ無視してよい
- **プロジェクトの規約**: `.agents/skills/team-standards/references/STANDARDS_TEMPLATE.md` に書く (更新しても残る)。`team-standards` の `SKILL.md` の `paths` を変えていた場合は、配布元の値に戻るので、退避先の `SKILL.md` を見て入れ直す
- **`.cursor/agents/*.md`**: 配布元の内容で上書きされる。書き換えていた場合は、Git の差分で確かめる
- **DADS の版**: 要求仕様の制約条件は人が判断して直す。`update.sh` が表示する制約行を貼り直す。古い版を書いている `docs/requirements/` の仕様書も表示される

## このリポジトリの版を上げる

### 1. 配布元の新しい版を確かめる

| 構成要素 | `versions.env` のキー | 確かめる場所 |
| --- | --- | --- |
| CKMS | `CKMS_REF` | <https://github.com/shioki/Cursor-Knowledge-Management-System/releases> |
| requirements-to-spec-template | `SPEC_REF` | <https://github.com/shioki/requirements-to-spec-template/blob/main/CHANGELOG.md> |
| DADS (サイト) | `DADS_VERSION` | <https://design.digital.go.jp/dads/updates-dads/> |
| `@digital-go-jp/design-tokens` | `DADS_TOKENS_VERSION` | `npm view @digital-go-jp/design-tokens version` |
| `@digital-go-jp/tailwind-theme-plugin` | `DADS_TAILWIND_PLUGIN_VERSION` | `npm view @digital-go-jp/tailwind-theme-plugin version` と、[バージョン対応表](https://github.com/digital-go-jp/tailwind-theme-plugin) |

`CKMS_REF` は v6.2.0 以上にします。v6.1.1 以前は、再実行で導入先の記録が消えます。

変更内容のうち、次に当たるものがあれば、`bootstrap.sh` やひな形も直す必要があります。

- `init.sh` と `install.sh` のオプション (`--yes`、`--with-agents-md`) と、実行する順番の前提 (CKMS の `init.sh` は既存の `AGENTS.md` を上書きしない)
- スキルの数 (CKMS 13、要求仕様 3、計 16)。変わったら `scripts/test-bootstrap.sh`、`scripts/test-update.sh`、README の数を直す
- 再実行の挙動 (CKMS は記録と `references/*_TEMPLATE.md` を残し、置き換える前に退避する。requirements-to-spec-template は自分の3スキルと `AGENTS.md` の節だけを置き換える)。`update.sh` はこの挙動を前提にしている
- `AGENTS.md` の begin / end の目印
- 導入後の案内で示すファイル (`team-standards/references/STANDARDS_TEMPLATE.md`、`requirements-spec/scripts/check_ids.py`)
- DADS のサイトの URL (`templates/design-README.md` のリンク) と、Tailwind CSS のテーマプラグインの読み込み方 (`bootstrap.sh` の案内)
- 要求仕様の制約条件の書き方 (`templates/design-README.md` の制約行)

### 2. versions.env を変えて試す

作業ブランチを作り、`versions.env` の値を書き換えます。

```bash
git switch -c chore/bump-versions
# versions.env を編集する
bash scripts/test-bootstrap.sh
bash scripts/test-update.sh
```

どちらも CI の結合試験と同じ内容です。

- `scripts/test-bootstrap.sh`: 空の Git リポジトリに導入し、スキルの配置、`validate.sh`、`AGENTS.md` の節、再実行の中止、`--with-tailwind` を確かめる
- `scripts/test-update.sh`: 古い版 (CKMS v6.2.3、DADS v2.17.0 など) で導入したプロジェクトを `update.sh` で更新し、記録が残ることなどを確かめる。試験の中の古い版は、`versions.env` の版より古いままにしておく

`CHANGELOG.md` の `[Unreleased]` の `### Changed` に、上げた版を旧版と新版で書きます。例: `CKMS を v6.2.4 から v6.3.0 に上げた`

コミットして push し、Pull Request を作ります。CI (shellcheck、markdownlint、lychee、結合試験) が通ることを確かめます。

### 3. リリースする

作業ブランチの上で、次の順に進めます。

1. `chore: vX.Y.Z をリリース` のコミットを積む。`CHANGELOG.md` の `[Unreleased]` を `[X.Y.Z] - YYYY-MM-DD` に確定し、末尾のリンクを直す
    - `[Unreleased]: https://github.com/shioki/web-app-starter-kit/compare/vX.Y.Z...HEAD`
    - `[X.Y.Z]: https://github.com/shioki/web-app-starter-kit/compare/v<前の版>...vX.Y.Z`
    - README の `--branch` の版 (導入手順と、導入済みのプロジェクトの更新の2か所) を `vX.Y.Z` に直す
2. そのコミットに注釈付きタグを打ち、タグを push する

    ```bash
    git tag -a vX.Y.Z -m "vX.Y.Z"
    git push origin vX.Y.Z
    git push
    ```

    タグを先に push するのは、CHANGELOG の compare URL がタグ無しでは 404 になり、lychee が失敗するためです。
3. Pull Request の CI が通ってからマージする
4. GitHub Release を作る。本文は CHANGELOG の `[X.Y.Z]` の節にする

    ```bash
    gh release create vX.Y.Z --verify-tag --title vX.Y.Z --notes-file <CHANGELOG の節を書いたファイル>
    ```

push 済みのタグは動かしません。リリース後に見つかった修正は、タグの後ろに積んで `[Unreleased]` に書きます。
