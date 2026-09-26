# 引き継ぎ: 3点セット導入リポジトリの新規構築

作成日: 2026-09-26
更新日: 2026-09-26(リポジトリへ保存。名前と公開範囲を確定。CKMS v6.2.4 に合わせて 4.1 節、5.2 節、5.3 節、7 章 P2・P3、8 章を修正。P3 の更新方式と退避の扱いを 2 章の合意事項に追加。CKMS の AGENTS.md テンプレートには begin / end の目印が無いため、5.4 節と 7 章 P1-5・P3-1 の完了条件を2種類に修正)
作業環境: Cursor
前提の作業: `shioki/requirements-to-spec-template` を v0.4.0 までリリース済み。CKMS を v6.2.4 までリリース済み

このファイルを読んで、このリポジトリの残りを実装してください。設計の判断が必要な箇所には推奨案を書いています。推奨と違う方針にする場合は、作業前にユーザーに確認してください。

## リポジトリ作成時点で確定していること

12 章の確認項目のうち、名前と公開範囲は確定済みです。方式は 5.1 節の推奨(導入スクリプト)のままです。まだ実装していません。

- リポジトリ名: `web-app-starter-kit`
- 公開範囲: Public
- リモート: <https://github.com/shioki/web-app-starter-kit>
- 済んでいる作業: `README.md`(目的のみ)。導入スクリプト、版の一覧、ライセンス、CI は未着手
- 本文の「新しいリポジトリを構築する」は、7 章の残りをこのリポジトリで実装する意味で読む

---

## 1. 目的

新規のWebアプリ開発プロジェクトを作るとき、次の3つ(以下「3点セット」)を一括で導入できるようにする。

| 構成要素 | 役割 | 取得元 |
| --- | --- | --- |
| Cursor Knowledge Management System(CKMS) | 技術判断・パターン・デバッグ記録などの知識管理(Agent Skills、hooks、subagent) | <https://github.com/shioki/Cursor-Knowledge-Management-System> |
| requirements-to-spec-template | Webアプリの要求仕様(テンプレート、Agent Skills、ID検査) | <https://github.com/shioki/requirements-to-spec-template> |
| デジタル庁デザインシステム(DADS) | 画面設計とアクセシビリティの基準 | <https://design.digital.go.jp/dads/> |

新リポジトリは、3つの中身を持たない。**どの版を組み合わせるかを決め、その版を取得して配置する**ことだけを担当する。

## 2. これまでに決まっていること

ユーザーと合意済みの方針です。変えないでください。

- requirements-to-spec-template は Webアプリ専用にした(v0.3.0)。リポジトリ名は変えない
- 3点セットの導入手順は、専用の別リポジトリ(このファイルで作るもの)に置く
- 新規のWebアプリのリポジトリを作るときに、この専用リポジトリを参照して3点セットを一括で導入する
- フロントエンドの技術スタックは固定しない。Tailwind CSS を使う場合の選択肢だけを用意する
- 3つの中身を新リポジトリに複製しない。版を固定して、配布元から取得する
  - CKMS の AGENTS.md に「配布物を複製しない」という規約がある。v5 で二重管理した結果、7つの SKILL.md すべてが食い違った経験に基づく
  - 複製すると、作った時点の内容で止まり、更新できなくなる
- 導入済みのプロジェクトの更新は、`bootstrap.sh` ではなく更新用の `scripts/update.sh` で行う。CKMS の `init.sh` と requirements-to-spec-template の `install.sh` を、新しい版で再実行する(7 章 P3、2026-09-26 合意)
- 更新時の CKMS の退避(`.agents/skills.backup-*/`)は作る。Git には入れず、導入先の `.gitignore` で除外する(同上)

## 3. リポジトリ名の候補

ユーザーに選んでもらってください。

| 候補 | 良い点 | 気になる点 |
| --- | --- | --- |
| `web-app-starter-kit`(推奨) | 何をするリポジトリかが一目で分かる。英語圏の慣習にも合う | 3点セットの中身は名前から読めない |
| `webapp-foundation` | 「全プロジェクトの土台」という位置付けが伝わる | テンプレートやフレームワークと誤解されうる |
| `web-project-bootstrap` | 「最初に一度実行する導入スクリプト」という性質が正確 | bootstrap は CSS フレームワークの Bootstrap と紛らわしい |
| `spec-knowledge-design-starter` | 要求仕様・知識管理・デザインの3要素を名前で表す | 長い。構成要素が変わると名前が合わなくなる |
| `triad-web-starter` | 「3点セット」を短く表す | triad の意味が伝わりにくい |

以降の本文では、仮に `web-app-starter-kit` と書きます。決まった名前に読み替えてください。

## 4. 構成要素の現状(2026-09-26 時点で確認済み)

### 4.1 CKMS(v6.2.4)

- 導入: `bash skills/project-setup/scripts/init.sh <導入先> [--yes] [--legacy-claude|--cursor-only] [--with-agents-md] [--no-hooks] [--no-agents] [--no-claude-bridge] [--no-backup]`。Windows は `init.ps1`
- 配置先: `.agents/skills/`(Cursor・Codex が直接読む)。Claude Code 向けに `.claude/skills` → `../.agents/skills` のシンボリックリンクを作る
- `--with-agents-md`: `AGENTS.md`(テンプレート)と `CLAUDE.md`(`@AGENTS.md` の1行)を作る。どちらも既存なら上書きしない。テンプレートには begin / end の目印が無く、ファイル全体が CKMS のテンプレートになる
- 構造検証: 導入先で `bash .agents/skills/project-setup/scripts/validate.sh`。v6.2.2 から、再実行の失敗で残った一時ディレクトリも警告し、退避先 `skills.backup-*` の件数を表示する
- `team-standards` の規約: v6.2.4 から `.agents/skills/team-standards/references/STANDARDS_TEMPLATE.md` に書く(再実行で残る)。frontmatter の `paths` は `SKILL.md` にあるため、再実行で初期値に戻る
- `gh skill install` などでスキルを個別に入れる場合は、`project-setup` も同じ場所に入れる。記録用スクリプト(`add-entry.sh` など)は `project-setup` の `_skill-base.sh` を使い、無いとエラーで止まる(v6.2.4)
- CKMS の規約: hook と知識管理のスクリプトは `jq` / `python` / `node` に依存させず、POSIX シェルと `sed` / `awk` / `find` で書く

**再実行の挙動(v6.2.0 で修正済み)**: v6.0.0〜v6.1.1 では、導入済みのプロジェクトで `init.sh --yes` を再実行すると `.agents/skills` を削除して作り直し、ほかの配布元のスキルと利用者の記録が消えていた。v6.2.0 以降の再実行は次のとおり動く(v6.2.4 で、requirements-to-spec-template の3スキルを入れた導入先に対して確認済み)。

- 置き換えるのは、配布元にある CKMS の13スキルだけ。requirements-to-spec-template の3スキルは「配布元に無いので残しました」と表示して残す
- `decisions/`・`patterns/`・`improvements/` の記録と `references/*_TEMPLATE.md` は残す
- 置き換える前に `.agents/skills.backup-YYYYmmdd-HHMMSS/` へ退避する(`--no-backup` で省略)。導入先の `.gitignore` には入らない(`.cursorignore` には除外が入る)
- `SKILL.md` は配布元の内容になる。版を上げると、書き換えていなくても「配布元と異なります」と警告が出る
- `AGENTS.md`、`CLAUDE.md`、`.cursor/hooks.json`、既存の `.cursorignore` は上書きしない。`.cursor/agents/*.md` は `--yes` のとき上書きする
- 導入先に入っている `init.sh` を、その導入先自身に向けて実行するとエラーで止まる。CKMS を clone したほうの `init.sh` を使う

**CKMS_REF は v6.2.0 以上にする**。v6.1.1 以前を指定すると、更新時に記録が消える。

### 4.2 requirements-to-spec-template(v0.4.0)

- 導入: `bash scripts/install.sh <導入先> [--skills-dir DIR] [--with-agents-md]`
- 配置するもの:
  - スキル3つを `.agents/skills/` に置く。`requirements-spec` は自動選択、`draft-spec` と `review-spec` は `/` による明示起動
  - `docs/requirements/`、`docs/requirements/assets/screens/`、一覧の `docs/requirements/README.md` を作る
- 再実行すると、自分の3スキルだけを置き換える。`docs/requirements/` の既存ファイルは変更しない(冪等性を確認済み)
- `--with-agents-md`: 導入先の `AGENTS.md` に要求仕様の節を追記する。節は `<!-- requirements-to-spec-template:begin -->` と `<!-- requirements-to-spec-template:end -->` で囲まれ、再実行時は置き換わる。`AGENTS.md` が無ければ作る
- `gh skill install shioki/requirements-to-spec-template <スキル名> --agent cursor --pin v0.4.0` でも入る(`docs/requirements/` と `AGENTS.md` の節は作られない)

### 4.3 DADS

- サイトの版: v2.18.0(β版、リビングスタンダードとして頻繁に更新される)
- npm パッケージ:
  - `@digital-go-jp/design-tokens` 2.0.1
  - `@digital-go-jp/tailwind-theme-plugin` 1.0.1(peerDependencies: `tailwindcss ^3.4.17 || ^4.0.0`)
- サイトの版とパッケージの版は別の番号。版の一覧には両方を書く
- コンポーネントはライブラリではなく、見本のコード。導入スクリプトで入れる対象ではない
  - <https://github.com/digital-go-jp/design-system-example-components-react>(MIT)
  - <https://github.com/digital-go-jp/design-system-example-components-html>(MIT)
- アクセシビリティ: DADS は JIS X 8341-3:2016 への準拠を基本としている。ただし、DADS のコンポーネントを使うだけでは適合にならない。requirements-to-spec-template の非機能要求で、適合レベル(AA)と試験方法を決める
- requirements-to-spec-template は次の2つを要求している
  - 画面詳細の主要要素を DADS のコンポーネント名で書く
  - 準拠する DADS の版を制約条件(`制約-XX`)で固定する

## 5. 新リポジトリの設計(推奨案)

### 5.1 方式

**導入スクリプト方式を推奨します。** 新しいWebアプリのリポジトリを作ったあと、新リポジトリを版(タグ)を固定して取得し、導入スクリプトを実行します。

```bash
git clone --depth 1 --branch v0.1.0 https://github.com/shioki/web-app-starter-kit.git /tmp/web-app-starter-kit
bash /tmp/web-app-starter-kit/scripts/bootstrap.sh /path/to/new-web-app
```

CKMS と requirements-to-spec-template がどちらもこの形(clone してスクリプトを実行)なので、使い方がそろいます。

代替案として、GitHub のテンプレートリポジトリ(`gh repo create --template`)もあります。ただし、テンプレートリポジトリは中身を丸ごとコピーするため、新リポジトリ自身の README や CI まで導入先に入ります。また、導入スクリプトが各プロジェクトに複製されて古くなります。採用する場合は、ユーザーに確認してください。

### 5.2 版の一覧

版の一覧はシェルで読める `KEY=VALUE` 形式にします(`jq` などに依存させないため)。ファイル名の推奨は `versions.env` です。

```sh
# 3点セットの版。変えたら CHANGELOG に記録する
CKMS_REPO=https://github.com/shioki/Cursor-Knowledge-Management-System.git
CKMS_REF=v6.2.4
SPEC_REPO=https://github.com/shioki/requirements-to-spec-template.git
SPEC_REF=v0.4.0
DADS_VERSION=v2.18.0
DADS_TOKENS_VERSION=2.0.1
DADS_TAILWIND_PLUGIN_VERSION=1.0.1
```

導入先にも同じ内容を記録します(例: `.web-app-starter/versions.env`)。どの版で導入したかを後から確認でき、更新の起点にもなります。

### 5.3 bootstrap.sh の処理順

順番に意味があります。2 と 3 は入れ替えないでください。CKMS の `--with-agents-md` は既存の `AGENTS.md` を上書きしないため、requirements-to-spec-template が先に `AGENTS.md` を作ると、CKMS のテンプレートが入りません。

1. **前提の確認**: 導入先がディレクトリで、Git リポジトリであること。導入先に `.web-app-starter/versions.env` が既にあれば、導入済みとして中止し、`scripts/update.sh`(7 章 P3)を案内する。`bootstrap.sh` は初回導入だけを担当する(`docs/design/README.md` を作り直したり、版の記録と導入物の食い違いを生んだりしないため)
2. **CKMS**: `CKMS_REF` を浅く clone し、clone したほうの `init.sh <導入先> --yes --with-agents-md` を実行する
3. **requirements-to-spec-template**: `SPEC_REF` を浅く clone し、`install.sh <導入先> --with-agents-md` を実行する
4. **DADS**:
    - `docs/design/README.md` を作る。版(`DADS_VERSION`、トークンとプラグインの版)と、コンポーネント一覧・アクセシビリティ方針へのリンクを書く
    - 要求仕様の制約条件にそのまま貼れる行も書く。例: `| 制約-01 | 画面は DADS v2.18.0 に準拠する。デザイントークンは @digital-go-jp/design-tokens 2.0.1 を使う | ... |`
5. **AGENTS.md**: 3点セット全体の節を追記する。`<!-- web-app-starter-kit:begin -->` と `<!-- web-app-starter-kit:end -->` で囲み、再実行時は置き換える。内容の例は次のとおり
    - 画面は DADS のコンポーネントと固定した版に従う
    - アクセシビリティは JIS X 8341-3:2016 AA を目標にする(値は仕様書の非機能要求が優先)
    - 技術判断は CKMS の `/record-decision` で残し、要求仕様の `未解決-XX` の判断記録列から辿れるようにする
6. **版の記録**: `.web-app-starter/versions.env` を書く。導入先の `.gitignore` に `.agents/skills.backup-*/` が無ければ足す(無ければ `.gitignore` を作る)。初回導入では退避は作られないが、更新(7 章 P3)で作られる退避を最初から Git に入れないため
7. **検証**: CKMS の `validate.sh` を実行し、結果を表示する
8. **後片付け**: 一時 clone を削除する。導入したものの一覧と、次にやること(`/draft-spec` で最初の要求仕様を作る、など)を表示する

オプションの候補は次のとおりです。

- `--with-tailwind`: 導入先に `package.json` がある場合だけ、`npm install -D @digital-go-jp/tailwind-theme-plugin@<版>` を実行する
  - Tailwind CSS 本体の設定ファイルは編集しない。v3 では設定ファイルでプラグインを読み込み、v4 では CSS の `@plugin` で読み込むため、書き方の案内を表示するに留める
  - 技術スタックを固定しない方針のため、既定では npm を実行しない
- `--no-hooks` など CKMS のオプションの受け渡しは、必要になってから足す(最初は入れない)

### 5.4 既知の見た目の問題

CKMS の `AGENTS.md` テンプレートは末尾に注記(「このファイルは templates/AGENTS.md.template を元にしています」)がある。requirements-to-spec-template の節は、その後ろに追記される。気になる場合は、3点セットの節の中に「要求仕様の節は末尾にある」旨を書くか、並べ替えを検討する。ただし、requirements-to-spec-template 側の begin / end で囲まれた範囲は変えない。CKMS のテンプレートには begin / end の目印が無い(既存の `AGENTS.md` を上書きしないことで保たれる)ため、`AGENTS.md` の begin / end は requirements-to-spec-template と web-app-starter-kit の2種類になる。

## 6. 新リポジトリの構成(推奨)

```text
.
├── README.md                 # 目的、3点セットの説明、導入手順、更新手順
├── AGENTS.md                 # このリポジトリ自身の規約(Cursor / Claude Code / Codex 共通)
├── CLAUDE.md                 # @AGENTS.md の1行のみ
├── versions.env              # 3点セットの版
├── scripts/
│   └── bootstrap.sh          # 導入スクリプト
├── templates/
│   ├── AGENTS.starter.md     # 導入先 AGENTS.md に追記する3点セットの節
│   └── design-README.md      # 導入先 docs/design/README.md のひな形
├── docs/
│   └── updating.md           # 版の上げ方と、導入済みプロジェクトの更新方法
├── .github/
│   ├── workflows/ci.yml      # shellcheck、markdownlint、lychee、導入の結合試験
│   ├── ISSUE_TEMPLATE/
│   └── pull_request_template.md
├── .editorconfig
├── .gitignore
├── .markdownlint.jsonc       # requirements-to-spec-template と同じ設定でよい
├── CHANGELOG.md              # Keep a Changelog 形式
└── LICENSE                   # MIT(他の2リポジトリと同じ)
```

## 7. 作業バックログ

1項目1コミットで進めてください。各項目の「完了条件」を満たしてから次へ進みます。

### P1: 最初の導入ができる(v0.1.0)

1. **リポジトリの骨組み**: `README.md`(目的だけ)、`LICENSE`(MIT)、`.gitignore`、`.editorconfig`、`AGENTS.md`、`CLAUDE.md`、`CHANGELOG.md`
    - 完了条件: GitHub にリポジトリを作成済み。リポジトリ名はユーザーが決めたもの
2. **版の一覧**: `versions.env`(5.2 節)
3. **bootstrap.sh の本体**: 5.3 節の処理順 1〜3、6、8
    - 完了条件: 空の Git リポジトリに実行して、`.agents/skills/` に CKMS の13スキルと要求仕様の3スキル(計16)が並ぶ。`docs/requirements/README.md` がある。`.claude/skills` が `.agents/skills` を指す。`.gitignore` に `.agents/skills.backup-*/` がある
4. **DADS の配置**: 5.3 節の 4
5. **AGENTS.md の3点セットの節**: 5.3 節の 5
    - 完了条件: 2回実行しても、2種類の begin / end(requirements-to-spec-template と web-app-starter-kit)のそれぞれの節が1つずつしかない。CKMS のテンプレート(末尾の注記)も1つだけ
6. **検証の表示**: 5.3 節の 7
    - 完了条件: CKMS の `validate.sh` がエラー0件
7. **再導入の防止**: 5.3 節の 1 の中止処理
    - 完了条件: 導入済みのプロジェクトに再実行すると中止し、`.agents/skills/knowledge-management/references/decisions/` の既存ファイルが残っている
8. **CI**: `shellcheck`、`markdownlint-cli2`、`lychee`、結合試験
    - 結合試験の内容: 一時ディレクトリに `git init` → `bootstrap.sh` → ファイルの存在と `validate.sh` を確認 → 再実行が中止されることを確認
9. **README の導入手順**: 5.1 節のコマンド、前提(`git`、`bash`)、Windows の扱い(CKMS には `init.ps1` があるが、requirements-to-spec-template には PowerShell 版が無い。v0.1.0 では WSL か Git Bash を案内する)
10. **v0.1.0 のリリース**: CHANGELOG を確定し、タグと GitHub Release を作る(9 章の手順)

### P2: 使いやすくする

1. `--with-tailwind`(5.3 節)
2. 導入後の「次にやること」の案内の充実(`/draft-spec` の使い方、DADS の制約行の貼り方、`team-standards/references/STANDARDS_TEMPLATE.md` にプロジェクトの規約を書くこと)
3. `docs/updating.md`: 版を上げる手順(`versions.env` を変える → CI の結合試験 → リリース)

### P3: 導入済みプロジェクトの更新

方針はユーザーと合意済みです(2 章)。`bootstrap.sh` は導入済みのプロジェクトでは中止する(5.3 節の 1)ので、更新は `scripts/update.sh <導入先>` で行います。CKMS v6.2.0 で再実行が記録を残すようになったため、CKMS も requirements-to-spec-template も、配布元のスクリプトを新しい版で再実行すれば更新できます。

`update.sh` の処理順は次のとおりです。

1. **前提の確認**: 導入先に `.web-app-starter/versions.env` が無ければ、未導入として中止し、`bootstrap.sh` を案内する。あれば、新リポジトリの `versions.env` と比べて、上がる版を表示する。上がる版が無ければ、その旨を表示して終了する
2. **CKMS**: 新しい `CKMS_REF` を浅く clone し、clone したほうの `init.sh <導入先> --yes --with-agents-md` を実行する(導入先の中の `init.sh` は使えない。4.1 節)。`--no-backup` は渡さない
3. **requirements-to-spec-template**: 新しい `SPEC_REF` を浅く clone し、`install.sh <導入先> --with-agents-md` を実行する(自分の3スキルと `AGENTS.md` の節だけを置き換える)
4. **DADS**: `docs/design/README.md` の版の記載を更新する。要求仕様の `制約-XX` は書き換えず、版が変わった旨と貼り直す行を表示する(仕様書の変更は人が判断する)
5. **AGENTS.md と版の記録**: `AGENTS.md` の3点セットの節を置き換え、`.web-app-starter/versions.env` を書き換える。`.gitignore` に `.agents/skills.backup-*/` が無ければ足す(`bootstrap.sh` の 6 と同じ処理。v0.1.0 より前の手順で導入したプロジェクトのため)
6. **検証**: CKMS の `validate.sh` を実行し、結果を表示する
7. **後片付けと案内**: 一時 clone を削除する。次を表示する
    - CKMS の退避先(`.agents/skills.backup-YYYYmmdd-HHMMSS/`)の場所。確認が済んだら削除してよいこと
    - 版を上げると、`SKILL.md` が変わったスキルでは「`SKILL.md` は配布元と異なります」の警告が出る。書き換えていなければ無視してよいこと
    - `team-standards` の規約は `references/STANDARDS_TEMPLATE.md` に書くこと。`paths` を変えていた場合は、退避先の `SKILL.md` を見て入れ直すこと
    - `.cursor/agents/*.md` は配布元の内容で上書きされたこと

作業項目は次のとおりです。P1 と同じく1項目1コミットで進めます。

1. **update.sh の本体**: 上の 1〜3、5〜7
    - 完了条件: `bootstrap.sh` で導入したプロジェクトの `versions.env` の版を下げてから実行すると、16スキルが残り、`decisions/` の既存ファイルが残り、2種類の begin / end(requirements-to-spec-template と web-app-starter-kit)の節が1つずつ。`validate.sh` がエラー0件。`.gitignore` に退避先の除外が1行だけある
2. **DADS の版の更新**: 上の 4
3. **CI の結合試験**: `bootstrap.sh` → 記録を1件足す → `update.sh` → 1 の完了条件を確認 → 未導入のディレクトリで `update.sh` が中止されることを確認
4. **docs/updating.md**: `update.sh` の使い方と、7 の案内の内容。P2 の 3(版を上げる手順)と同じファイルにまとめる

採らなかった案は次のとおりです。

- `gh skill update`: `init.sh` で入れたスキルに gh skill の provenance が無く、hooks や `.claude/skills` の橋渡しも更新されない
- 手順書だけの手動更新: 手順が多く、`versions.env` の書き換え漏れが起きる
- `--no-backup`: `team-standards` の `paths` など、Git に入れる前の書き換えを戻せなくなる。退避は作り、`.gitignore` で Git から外す

## 8. 検証の手順(ローカル)

requirements-to-spec-template の v0.4.0 作業で実際に行った確認です。bootstrap.sh でも同じことを確かめてください。

```bash
tmp=$(mktemp -d) && git -C "$tmp" init -q
bash scripts/bootstrap.sh "$tmp"
ls "$tmp/.agents/skills" | wc -l                   # 16
readlink "$tmp/.claude/skills"                     # ../.agents/skills
(cd "$tmp" && bash .agents/skills/project-setup/scripts/validate.sh)   # エラー 0 件
grep -c 'requirements-to-spec-template:begin' "$tmp/AGENTS.md"         # 1
python3 "$tmp/.agents/skills/requirements-spec/scripts/check_ids.py" --help
bash scripts/bootstrap.sh "$tmp"; echo $?          # 中止され、0 以外
```

P3 の更新(CKMS の再実行)は、CKMS v6.2.4 と requirements-to-spec-template v0.4.0 で次を確認済みです。`update.sh` を作ったら、同じことを `update.sh` 経由で確かめてください(P3 の作業項目 1 の完了条件)。

```bash
echo test > "$tmp/.agents/skills/knowledge-management/references/decisions/2026-09-26-sample.md"
bash /tmp/ckms/skills/project-setup/scripts/init.sh "$tmp" --yes --with-agents-md
ls "$tmp/.agents/skills" | wc -l                   # 16 のまま
ls "$tmp/.agents/skills/knowledge-management/references/decisions/"   # 2026-09-26-sample.md が残る
grep -c 'requirements-to-spec-template:begin' "$tmp/AGENTS.md"         # 1
(cd "$tmp" && bash .agents/skills/project-setup/scripts/validate.sh)   # エラー 0 件
```

参考: `gh skill preview shioki/requirements-to-spec-template requirements-spec@v0.4.0` で、スキルの中身(テンプレートと画像を同梱)を確認できる。

## 9. 作業の規約

requirements-to-spec-template と同じ規約にそろえます。

- コミットメッセージは Conventional Commits(`feat:` / `fix:` / `docs:` / `ci:` / `chore:`)、件名と本文は日本語
- `main` に直接コミットしない。作業ブランチから Pull Request を作り、CI が通ってからマージする
- リリースは、作業ブランチに `chore: vX.Y.Z をリリース` のコミット(CHANGELOG の `[Unreleased]` を `[X.Y.Z] - YYYY-MM-DD` に確定し、compare URL を足す)を積む。そのコミットに注釈付きタグ(`git tag -a vX.Y.Z -m "vX.Y.Z"`)を打ち、タグを push してから PR の CI を通してマージし、GitHub Release を作る
  - タグを先に push するのは、CHANGELOG の compare URL がタグ無しでは 404 になり、lychee が失敗するため
- push 済みのタグは動かさない。リリース後に見つかった修正は、タグの後ろに積んで `[Unreleased]` に書く
- シェルスクリプトは `set -eu`。`jq` / `python` / `node` に依存させない(`--with-tailwind` の npm は例外)。`shellcheck` を通す
- 括弧は半角 `()`。「適切に」「なるべく」「可能な限り」は使わない
- push、PR 作成、マージ、タグ、リリースは、ユーザーの指示を受けてから行う

## 10. 触らないこと

- CKMS と requirements-to-spec-template のリポジトリは、新リポジトリの作業では変更しない。必要な変更が見つかったら、内容をユーザーに報告する(Issue の下書きまで)
- requirements-to-spec-template の既存タグ(v0.1.0〜v0.4.0)と Release

## 11. このあと requirements-to-spec-template で予定していること(参考)

新リポジトリから実際に参照されたことを確認してから、requirements-to-spec-template の v1.0.0 を確定する予定です。v1.0.0 の候補は次のとおりです。

- `scripts/check_ids.py` の単体テスト
- 互換性の約束(IDの接頭辞、章の見出し、ファイルの場所を、v1.0 以降は破壊的変更をしない公開仕様とする)と、廃止の手順
- 仕様書に「どのテンプレートの版で書いたか」を記録する欄
- 禁止語(「適切に」など)と、担当者・期限が空の `未解決-XX` の機械的な検査
- `template-lite.md` への Web 向けの最低限の項目(権限、アクセシビリティ)

新リポジトリの作業中に requirements-to-spec-template へ足したい点が見つかったら、上の一覧に加える候補としてユーザーに報告してください。

## 12. 最初にユーザーに確認すること

1. リポジトリ名(3 章)
2. 方式: 導入スクリプト方式(推奨)か、GitHub のテンプレートリポジトリか(5.1 節)
3. 公開範囲: Public か Private か(他の2リポジトリは Public、MIT)
