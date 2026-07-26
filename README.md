# 2026-dsx-bravo-report

データサイエンス演習 最終レポート（グループ **Bravo**）の原稿リポジトリです。

原稿は **`src/2026-dsx-bravo/main.tex`** の1本だけです。ここを編集すると PDF ができます。

**ローカルに TeX をインストールする必要はありません。** ビルドはすべて Docker コンテナ
（`texlive/texlive:TL2025-historic`）の中で行うので、どのマシンでも同じ PDF が出ます。

## 最初に1回だけやること

1. [Docker Desktop](https://www.docker.com/products/docker-desktop/) をインストールして起動する
2. 動作確認：

   ```sh
   make pdf
   ```

初回は TeX Live イメージ（数 GB）のダウンロードが走るので **10 分以上かかることがあります**。
2 回目以降は数十秒です。`src/2026-dsx-bravo/main.pdf` ができれば成功です。

## 書く

```sh
make watch     # 保存するたびに自動で PDF が焼き直される（Ctrl+C で終了）
```

`make` のコマンドは `DOC` を省略すると `src/2026-dsx-bravo` を見にいきます。
このリポジトリの文書はこれ1本なので、**基本 `DOC=` は付けなくて構いません。**

### コマンド一覧

| コマンド | 内容 |
|---|---|
| `make pdf` | PDF を 1 回ビルド |
| `make watch` | 変更を監視して自動再ビルド（Ctrl+C で終了） |
| `make clean` | 生成物（`aux` などの中間ファイルと PDF）を削除 |
| `make archive` | 提出用 zip（PDF 込み）を生成 |
| `make list` | テンプレートと `src/` の文書を一覧表示 |
| `make shell` | コンテナ内のシェルに入る（デバッグ用） |

## 原稿の中身

| ファイル | 内容 |
|---|---|
| `src/2026-dsx-bravo/main.tex` | 本文。ここを書く |
| `src/2026-dsx-bravo/appendix.tex` | 付録（実験に用いたソースコード） |
| `src/2026-dsx-bravo/sample.png` | 図の差し替え用サンプル画像 |
| `src/2026-dsx-bravo/fundsx.sty` | 配布されたスタイルファイル。**触らない** |
| `src/2026-dsx-bravo/latexmkrc` | ビルド設定（upLaTeX → dvipdfmx）。**触らない** |

`main.tex` の章立ては配布テンプレートのままです。`＜　＞` で囲まれた部分が
指示文なので、書いたら消してください。

1. 概要
2. 背景・目的
3. 対象としたデータセット
4. 手法
5. 実装（実験）
6. 結果
7. 結論・考察
8. 参考文献 → 付録（ソースコード）

書くときに効いてくる、テンプレート側の指定：

- **結論・考察は 400 字以上。** 個々人で書く場合は氏名を明記の上、ひとり 150 字以上
- 実装の章には**作業分担**を書く（この段落はグループ内で共有してよい）
- 図には必ずキャプションを付け、本文から `図\ref{fig:1}` の形で参照する
- プロットはタイトル・縦軸・横軸、複数条件なら凡例を忘れずに
- URL は `\url{https://.../}` で書く

## エディタ

### VS Code

1. 拡張機能「Dev Containers」を入れる
2. このフォルダを開き、右下の通知から **「Reopen in Container」** を選ぶ
3. `.tex` を編集して保存するだけで自動ビルドされ、PDF プレビューが更新される
   （LaTeX Workshop が自動で入ります。PDF 上で ⌘クリックすると該当ソースに飛べます）

### neovim など好きなエディタ

ターミナルで監視ビルドを立ち上げておき、いつものエディタで編集します：

```sh
make watch   # Ctrl+C で終了
```

## 提出用の zip を作る

```sh
make archive
```

`2026-dsx-bravo_YYYYMMDD.zip` がリポジトリ直下にできます。PDF と `.tex` 一式が入り、
`aux` / `log` などの中間生成物は除外されます。zip 自体は `.gitignore` 済みなので
コミットされません。

## PDF の自動ビルドと共有

`main` に push すると GitHub Actions が `src/` 配下の文書をビルドし、次の 2 か所に置きます。

- **GitHub Pages** — <https://wisteriahuman.github.io/2026-dsx-bravo-report/> に PDF が並びます。
  グループのメンバーに「今の版」を見せるのはこれが早いです
- **Actions の Artifacts** — `pdfs` という名前で PDF がダウンロードできます

Pages を使うには、リポジトリの **Settings → Pages → Source** を **GitHub Actions** に
設定してください（1回だけ）。

`site/index.html` のリポジトリリンクは `{{REPO_URL}}` プレースホルダで、CI が
`GITHUB_SERVER_URL` と `GITHUB_REPOSITORY` から自動で埋めます。

## 守ること

- 生成 PDF と中間生成物（`aux` など）はコミットしない（`.gitignore` 済み）
- 配布元から受け取った `fundsx.sty` と `latexmkrc` は**変更しない**。提出物の体裁が変わります
- イメージのタグ `TL2025-historic` は勝手に変えない。TeX Live のバージョンが変わると
  組版結果がずれます

## トラブルシューティング

- `Cannot connect to the Docker daemon` → Docker Desktop が起動しているか確認
- `missing separator` → `Makefile` のレシピ行がタブでなくスペースになっています
- ビルドが通らない → `make clean && make pdf` を試す。
  それでもダメなら `src/2026-dsx-bravo/main.log` の後ろの方を見る
- 日本語が化ける・フォントエラー → イメージのタグが `TL2025-historic` のままか確認

## 付録：テンプレートから別の文書を起こす

このリポジトリは LaTeX 文書用の雛形リポジトリから作られており、その仕組みが残っています。
`templates/` はテンプレートの**原本**置き場で、**直接編集しません。**
`make new` でコピーを `src/` に作り、そちらを編集します。

```sh
make new FROM=fundsx NAME=2026-dsx-2   # templates/fundsx → src/2026-dsx-2
make watch DOC=src/2026-dsx-2          # DOC で対象を明示する
```

| 名前 | エンジン | 内容 |
|---|---|---|
| `minimal` | upLaTeX → dvipdfmx | `jsarticle` のみ。独自 `.sty` に依存しない汎用テンプレート |
| `fundsx` | upLaTeX → dvipdfmx | データサイエンス演習 最終レポートの配布テンプレート（`ujarticle` + `fundsx.sty`）。`src/2026-dsx-bravo` はこれのコピー |

`Makefile` はコンテナの作業ディレクトリを文書ディレクトリに移して `latexmk` を実行するので
（`docker compose run -w /workdir/$(DOC)`）、エンジンは各文書の `latexmkrc` が決めます。
配布されたテンプレートを**中身を書き換えずに `templates/` へ置くだけ**でビルドできるのは
このためです。

**ディレクトリ名にスペースを入れないでください。** Make は変数展開後の空白を引数の区切りとして
扱うため、`groupReportTexFormat-2026 (1)` のような名前は `DOC=` に渡した時点で壊れます。
