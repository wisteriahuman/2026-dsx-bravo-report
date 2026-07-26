DATE := $(shell date +%Y%m%d)
DOC ?= src/2026-dsx-bravo-report
RUN := docker compose run --rm -w /workdir/$(DOC) latex
ARCHIVE := $(notdir $(DOC))_$(DATE).zip

.PHONY: list new check pdf watch clean archive shell

## テンプレートと作業中の文書を一覧表示する
list:
	@echo "templates/ (原本):"
	@ls templates 2>/dev/null | sed 's/^/  /'
	@echo "src/ (作業中):"
	@ls src 2>/dev/null | sed 's/^/  /'

## テンプレから新しい文書を作る: make new FROM=minimal NAME=2026-report
new:
	@test -n "$(FROM)" && test -n "$(NAME)" || { echo "使い方: make new FROM=<テンプレ名> NAME=<文書名>"; exit 1; }
	@test -d "templates/$(FROM)" || { echo "テンプレートがありません: templates/$(FROM)"; exit 1; }
	@test ! -e "src/$(NAME)" || { echo "すでにあります: src/$(NAME)"; exit 1; }
	@cp -R "templates/$(FROM)" "src/$(NAME)"
	@echo "==> src/$(NAME) を作成しました"
	@echo "    make watch DOC=src/$(NAME)"

check:
	@test -f "$(DOC)/main.tex" || { \
	  echo "エラー: $(DOC)/main.tex がありません"; \
	  echo "使い方: make pdf DOC=src/<文書名>"; \
	  $(MAKE) --no-print-directory list; exit 1; }

## PDFを1回ビルドする
pdf: check
	$(RUN) latexmk main.tex

## ファイル変更を監視して自動再ビルド (Ctrl+Cで終了)
watch: check
	$(RUN) latexmk -pvc -view=none main.tex

## 生成物を削除する
clean: check
	$(RUN) latexmk -C main.tex

## 提出用zipを作る (PDF込み)
archive: pdf
	@rm -f "$(ARCHIVE)"
	cd "$(DOC)" && zip -r "$(CURDIR)/$(ARCHIVE)" . \
	  -x '*.DS_Store' -x '*.aux' -x '*.log' -x '*.dvi' \
	  -x '*.fls' -x '*.fdb_latexmk' -x '*.synctex.gz'
	@echo "==> $(ARCHIVE) を作成しました"

## コンテナ内のシェルに入る (デバッグ用)
shell: check
	$(RUN) bash
