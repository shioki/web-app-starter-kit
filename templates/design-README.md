# 画面設計

このプロジェクトの画面は、デジタル庁デザインシステム (DADS) の固定した版に従います。この版は web-app-starter-kit で導入したときに決まりました。

## 準拠する版

| 対象 | 版 | 参照先 |
| --- | --- | --- |
| DADS (サイト) | {{DADS_VERSION}} | <https://design.digital.go.jp/dads/> |
| デザイントークン `@digital-go-jp/design-tokens` | {{DADS_TOKENS_VERSION}} | <https://github.com/digital-go-jp/design-tokens> |
| Tailwind CSS のテーマ `@digital-go-jp/tailwind-theme-plugin` (Tailwind CSS を使う場合) | {{DADS_TAILWIND_PLUGIN_VERSION}} | <https://github.com/digital-go-jp/tailwind-theme-plugin> |

サイトの版とパッケージの版は別の番号です。DADS はリビングスタンダードとして頻繁に更新されるため、版を上げるときは要求仕様の制約条件とこの表を一緒に直します。サイトの更新内容は [お知らせ (ドキュメント)](https://design.digital.go.jp/dads/updates-dads/) で確認できます。

## 要求仕様の制約条件に貼る行

要求仕様書 (`docs/requirements/`) の「制約条件」の表に、次の行を貼ります。ID の番号は仕様書に合わせて振り直してください。

```markdown
| 制約-01 | 画面はデジタル庁デザインシステム(DADS) {{DADS_VERSION}} に準拠する。デザイントークンは `@digital-go-jp/design-tokens` {{DADS_TOKENS_VERSION}} を使う | 画面設計とアクセシビリティの基準をそろえる | フロントエンド全体 |
```

Tailwind CSS を使う場合は、次の行も貼ります。

```markdown
| 制約-02 | Tailwind CSS のテーマは `@digital-go-jp/tailwind-theme-plugin` {{DADS_TAILWIND_PLUGIN_VERSION}} を使う | DADS のデザイントークンを Tailwind CSS から使う | フロントエンド全体 |
```

## コンポーネント

- 一覧: <https://design.digital.go.jp/dads/components/>
- 要求仕様の画面詳細では、主要要素を DADS のコンポーネント名で書きます。DADS に無い要素は「独自」と書き、理由を添えます
- DADS のコンポーネントはライブラリではなく見本のコードです。使うときは、次のリポジトリから必要なものをプロジェクトに取り込みます (どちらも MIT)
  - React: <https://github.com/digital-go-jp/design-system-example-components-react>
  - HTML: <https://github.com/digital-go-jp/design-system-example-components-html>

## アクセシビリティ

- DADS の方針: <https://design.digital.go.jp/dads/webaccessibility/>
- DADS は JIS X 8341-3:2016 への準拠を基本としています。ただし、DADS のコンポーネントを使うだけでは適合になりません
- 目標とする適合レベル (既定の目標は AA)、対象の範囲、試験方法は、要求仕様の非機能要求で決めます。値は仕様書が優先します
