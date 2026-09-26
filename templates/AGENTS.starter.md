<!-- web-app-starter-kit:begin -->
## 3点セット (web-app-starter-kit)

このプロジェクトには、web-app-starter-kit で CKMS (知識管理)、requirements-to-spec-template (要求仕様)、デジタル庁デザインシステム (DADS) を導入した。導入した版は `.web-app-starter/versions.env` にある。

- 画面は DADS のコンポーネントと、`docs/design/README.md` に書いた DADS の版に従う。DADS に無い要素を作るときは、要求仕様の画面詳細に「独自」と理由を書く
- アクセシビリティは JIS X 8341-3:2016 の適合レベル AA を目標にする。要求仕様の非機能要求に値があれば、そちらを優先する
- 技術判断は CKMS の `/record-decision` で残す。要求仕様の `未解決-XX` を解決したら、判断記録の場所を `判断記録` 列に書き、仕様書から辿れるようにする
- 要求仕様の読み方と書き方は、この節の直前の「要求仕様」の節にある
- `.agents/skills/` の `SKILL.md` は配布物で、更新すると配布元の内容に戻る。プロジェクトの規約は `.agents/skills/team-standards/references/STANDARDS_TEMPLATE.md` に書く
<!-- web-app-starter-kit:end -->
