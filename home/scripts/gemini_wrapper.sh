#!/usr/bin/env bash

# スクリプト終了時（正常終了、エラー、割り込み等）に必ず export を実行して
# $EDITOR を `nvim` に戻す
trap 'export EDITOR="nvim"' EXIT

# 一時的に $EDITOR を `nvim_ime` に変更
export EDITOR="nvim_ime"

# gemini コマンドを実行（引数があれば引数も渡す）
gemini "$@"

# nvim の終了コードを保存して終了
exit $?

