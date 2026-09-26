# 版の上げ方

3点セットの版は [versions.env](../versions.env) だけで固定しています。この文書は、`versions.env` の版を上げて web-app-starter-kit の新しい版をリリースする手順です。

導入済みのプロジェクトを新しい版に更新する手順 (`scripts/update.sh`) は、今後の版で追加します。`bootstrap.sh` は初回導入だけを担当し、導入済みのプロジェクトでは中止します。

## 1. 配布元の新しい版を確かめる

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
- スキルの数 (CKMS 13、要求仕様 3、計 16)。変わったら `scripts/test-bootstrap.sh` と README の数を直す
- `AGENTS.md` の begin / end の目印
- 導入後の案内で示すファイル (`team-standards/references/STANDARDS_TEMPLATE.md`、`requirements-spec/scripts/check_ids.py`)
- DADS のサイトの URL (`templates/design-README.md` のリンク) と、Tailwind CSS のテーマプラグインの読み込み方 (`bootstrap.sh` の案内)
- 要求仕様の制約条件の書き方 (`templates/design-README.md` の制約行)

## 2. versions.env を変えて試す

作業ブランチを作り、`versions.env` の値を書き換えます。

```bash
git switch -c chore/bump-versions
# versions.env を編集する
bash scripts/test-bootstrap.sh
```

`scripts/test-bootstrap.sh` は CI の結合試験と同じ内容です。空の Git リポジトリに導入し、スキルの配置、`validate.sh`、`AGENTS.md` の節、再実行の中止、`--with-tailwind` を確かめます。

`CHANGELOG.md` の `[Unreleased]` の `### Changed` に、上げた版を旧版と新版で書きます。例: `CKMS を v6.2.4 から v6.3.0 に上げた`

コミットして push し、Pull Request を作ります。CI (shellcheck、markdownlint、lychee、結合試験) が通ることを確かめます。

## 3. リリースする

作業ブランチの上で、次の順に進めます。

1. `chore: vX.Y.Z をリリース` のコミットを積む。`CHANGELOG.md` の `[Unreleased]` を `[X.Y.Z] - YYYY-MM-DD` に確定し、末尾のリンクを直す
    - `[Unreleased]: https://github.com/shioki/web-app-starter-kit/compare/vX.Y.Z...HEAD`
    - `[X.Y.Z]: https://github.com/shioki/web-app-starter-kit/compare/v<前の版>...vX.Y.Z`
    - README の導入手順の `--branch` の版を `vX.Y.Z` に直す
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
