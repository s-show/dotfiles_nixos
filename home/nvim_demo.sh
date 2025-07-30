#!/usr/bin/env bash

# スクリプト終了時（正常終了、エラー、割り込み等）に必ず unset を実行
trap 'unset NVIM_APPNAME' EXIT

# 環境変数 NVIM_APPNAME に ~/.config/nvim_demo をセット
export NVIM_APPNAME="nvim_demo"

# nvim コマンドを実行（引数があれば引数も渡す）
nvim "$@"

# nvim の終了コードを保存して終了
exit $?
