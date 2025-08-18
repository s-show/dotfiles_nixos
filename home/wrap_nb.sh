#!/usr/bin/env bash

# nb起動用スクリプト
# SSH鍵の追加を確認してからnbを実行する

# 色付きメッセージ用の定数
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# SSH鍵のパスを設定（必要に応じて変更してください）

SSH_KEY_PATH="$HOME/.ssh/id_ed25519"

echo -e "${YELLOW}nb起動準備中...${NC}"

# ssh-agentが起動しているかチェック
if ! ssh-add -l &>/dev/null; then

    echo -e "${YELLOW}SSH agent が起動していません。起動中...${NC}"
    eval "$(ssh-agent -s)"
fi

# SSH agentの状態をチェック

SSH_LIST_OUTPUT=$(ssh-add -l 2>&1)
SSH_LIST_EXIT_CODE=$?


# デバッグ情報（必要に応じてコメントアウト）
echo -e "${YELLOW}Debug: ssh-add -l の出力:${NC}"
echo "$SSH_LIST_OUTPUT"
echo -e "${YELLOW}Debug: 終了コード: $SSH_LIST_EXIT_CODE${NC}"


# 既にSSH鍵が追加されているかチェック
if [ $SSH_LIST_EXIT_CODE -eq 0 ]; then

    # 鍵のパスまたはフィンガープリントで確認
    if echo "$SSH_LIST_OUTPUT" | grep -q "id_ed25519" || echo "$SSH_LIST_OUTPUT" | grep -q "ED25519"; then
        echo -e "${GREEN}SSH鍵は既に追加されています。${NC}"
        echo -e "${GREEN}nb を起動します...${NC}"
        exec nb "$@"
    else

        echo -e "${YELLOW}ED25519鍵が見つかりません。別の鍵が登録されています。${NC}"
    fi
elif [ $SSH_LIST_EXIT_CODE -eq 1 ]; then
    echo -e "${YELLOW}SSH agentに鍵が登録されていません。${NC}"
else
    echo -e "${YELLOW}SSH agentでエラーが発生しました。${NC}"

fi


echo -e "${YELLOW}SSH鍵を追加します...${NC}"

# SSH鍵を追加（パスフレーズの入力が必要）
if ssh-add "$SSH_KEY_PATH"; then
    echo -e "${GREEN}SSH鍵の追加に成功しました。${NC}"
    echo -e "${GREEN}nb を起動します...${NC}"
    exec nb "$@"
else
    echo -e "${RED}SSH鍵の追加に失敗しました。パスフレーズが正しくないか、鍵ファイルが見つかりません。${NC}"
    echo -e "${RED}nb は起動されません。${NC}"
    exit 1
fi
