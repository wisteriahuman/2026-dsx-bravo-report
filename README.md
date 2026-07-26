# latex-templates

LaTeX 文書リポジトリの雛形です。**GitHub のテンプレートリポジトリとして使います。**
文書を1本書くごとに、ここから新しいリポジトリを起こしてください。

**ローカルに TeX をインストールする必要はありません。** ビルドはすべて Docker コンテナ
（`texlive/texlive:TL2025-historic`）の中で行うので、どのマシンでも同じ PDF が出ます。

## 使いはじめる

1. このリポジトリで **「Use this template」→「Create a new repository」** を押す
2. できた新リポジトリを clone する
3. 学校や学会から配布されたテンプレートがあれば、**`templates/` にディレクトリごと置く**
4. `make new` で `src/` にコピーし、そこで書く

このリポジトリ自体は空の雛形なので、ここに文書を書き足していくのではなく、
**コピーしてから書く**のが基本の流れです。

## 構成

```
├── templates/        原本。ここは書き換えない
│   └── minimal/
├── src/              実作業。ここで書く
├── site/             GitHub Pages のトップページ（文書一覧）
├── compose.yaml      TeX Live コンテナの定義
└── Makefile
```

`templates/` はテンプレートの原本置き場です。**直接編集しません。**
`make new` でコピーを `src/` に作り、そちらを編集します。原本は常に綺麗なまま残るので、
壊しても作り直せます。

### エンジンを固定しない設計

このリポジトリは upLaTeX / LuaLaTeX などの**エンジンを一切決めていません。**
決めているのは各文書ディレクトリの `latexmkrc` です。

`Makefile` はコンテナの作業ディレクトリを文書ディレクトリに移して `latexmk` を実行するので
（`docker compose run -w /workdir/$(DOC)`）、その中の `latexmkrc` が自動的に読まれます。
おかげで、大学や学会から配布されたテンプレートを **中身を一切書き換えずに `templates/` へ置くだけ** で
そのままビルドできます。

## 最初に1回だけやること

1. [Docker Desktop](https://www.docker.com/products/docker-desktop/) をインストールして起動する
2. 動作確認：

   ```sh
   make new FROM=minimal NAME=test
   make pdf DOC=src/test
   ```

初回は TeX Live イメージ（数 GB）のダウンロードが走るので **10 分以上かかることがあります**。
2 回目以降は数十秒です。`src/test/main.pdf` ができれば成功です。

## 使い方

```sh
make list                            # テンプレートと作業中の文書を一覧表示
make new FROM=minimal NAME=2026-report   # templates/minimal → src/2026-report にコピー
make watch DOC=src/2026-report       # 保存するたびに自動再ビルド
```

`DOC` は毎回指定します。省略時は `src/report` を見にいきます。

### コマンド一覧

| コマンド | 内容 |
|---|---|
| `make list` | テンプレートと作業中の文書を一覧表示 |
| `make new FROM=<テンプレ名> NAME=<文書名>` | テンプレートから新しい文書を作る |
| `make pdf DOC=<文書ディレクトリ>` | PDF を 1 回ビルド |
| `make watch DOC=<文書ディレクトリ>` | 変更を監視して自動再ビルド（Ctrl+C で終了） |
| `make clean DOC=<文書ディレクトリ>` | 生成物を削除 |
| `make archive DOC=<文書ディレクトリ>` | 提出用 zip（PDF 込み）を生成 |
| `make shell DOC=<文書ディレクトリ>` | コンテナ内のシェルに入る（デバッグ用） |

## 執筆スタイル別の使い方

### VS Code 派

1. 拡張機能「Dev Containers」を入れる
2. このフォルダを開き、右下の通知から **「Reopen in Container」** を選ぶ
3. `.tex` を編集して保存するだけで自動ビルドされ、PDF プレビューが更新される
   （LaTeX Workshop が自動で入ります。PDF 上で ⌘クリックすると該当ソースに飛べます）

`.vscode/settings.json` で `templates/` をルートファイル探索から除外しています。
原本を誤ってビルド対象にしないためです。

### neovim など好きなエディタ派

ターミナルで監視ビルドを立ち上げておき、いつものエディタで編集します：

```sh
make watch DOC=src/2026-report   # Ctrl+C で終了
```

## テンプレートを追加する

`templates/` に丸ごとコピーするだけです。中身は一切書き換えません。

```sh
cp -R ~/Downloads/20.dsx_finalreporttemplate templates/fundsx
make new FROM=fundsx NAME=2026-dsx
make watch DOC=src/2026-dsx
```

**ディレクトリ名にスペースを入れないでください。** Make は変数展開後の空白を引数の区切りとして
扱うため、`groupReportTexFormat-2026 (1)` のような名前は `DOC=` に渡した時点で壊れます。

### 収録テンプレート

| 名前 | エンジン | 内容 |
|---|---|---|
| `minimal` | upLaTeX → dvipdfmx | `jsarticle` のみ。独自 `.sty` に依存しない汎用テンプレート |

## PDF の自動ビルドと配布

`main` に push すると GitHub Actions が `src/` 配下の全文書をビルドし、次の 2 か所に置きます。

- **GitHub Pages** — 文書一覧のページが公開されます。ブラウザで見るだけの人はこれで十分です
- **Actions の Artifacts** — `pdfs` という名前で全 PDF がまとまってダウンロードできます

Pages を使うには、リポジトリの **Settings → Pages → Source** を **GitHub Actions** に
設定してください。

`src/` が空のあいだは Pages 関連のジョブを丸ごとスキップします。
**雛形リポジトリのままでも CI は赤くなりません。** `make new` で最初の文書を作って
push した時点から公開が始まります。

`site/index.html` のリポジトリリンクは `{{REPO_URL}}` プレースホルダで、CI が
`GITHUB_SERVER_URL` と `GITHUB_REPOSITORY` から自動で埋めます。
**fork やコピーで別リポジトリにしても書き換え不要です。**

## 運用ルール

- 生成 PDF と中間生成物（`aux` など）はコミットしない（`.gitignore` 済み）。
  ただし `templates/` 配下の見本 PDF は配布物の一部なので追跡対象に残しています
- 配布元から受け取った `.sty` と `latexmkrc` は**変更しない**。提出物の体裁が変わります
- イメージのタグ `TL2025-historic` は勝手に変えない。TeX Live のバージョンが変わると
  組版結果がずれます

## トラブルシューティング

- `Cannot connect to the Docker daemon` → Docker Desktop が起動しているか確認
- `missing separator` → `Makefile` のレシピ行がタブでなくスペースになっています
- ビルドが通らない → `make clean DOC=... && make pdf DOC=...` を試す。
  それでもダメなら `main.log` の後ろの方を見る
- 日本語が化ける・フォントエラー → イメージのタグが `TL2025-historic` のままか確認
