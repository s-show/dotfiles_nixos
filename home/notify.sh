#!/usr/bin/env zsh

# wsl-notify-send.exe のパス
# 優先順位：
# 1. 環境変数 WSL_NOTIFY_SEND_EXE（Home Managerで設定）
# 2. 動的に検索
WSL_NOTIFY_SEND_EXE="${WSL_NOTIFY_SEND_EXE:-}"

# wsl-notify-send.exe の実際のパスを見つける
find_wsl_notify_send() {
    # Nix store から wsl-notify-send.exe を探す
    local found_exe=$(find /nix/store -maxdepth 3 -name "wsl-notify-send.exe" -type f -executable 2>/dev/null | head -1)
    if [[ -n "$found_exe" ]] && [[ -x "$found_exe" ]]; then
        echo "$found_exe"
        return 0
    fi
    
    return 1
}

# 起動時に wsl-notify-send のパスを設定（環境変数がない場合のみ）
if [[ -z "$WSL_NOTIFY_SEND_EXE" ]] || [[ ! -x "$WSL_NOTIFY_SEND_EXE" ]]; then
    WSL_NOTIFY_SEND_EXE=$(find_wsl_notify_send)
fi

# notify-send が利用可能かチェック
check_notify_send() {
    if [[ -n "$WSL_NOTIFY_SEND_EXE" ]] && [[ -x "$WSL_NOTIFY_SEND_EXE" ]]; then
        return 0
    else
        echo "Error: wsl-notify-send.exe not found at $WSL_NOTIFY_SEND_EXE" >&2
        echo "Trying to find it..." >&2
        WSL_NOTIFY_SEND_EXE=$(find_wsl_notify_send)
        if [[ -n "$WSL_NOTIFY_SEND_EXE" ]]; then
            echo "Found at: $WSL_NOTIFY_SEND_EXE" >&2
            return 0
        else
            echo "Could not find wsl-notify-send.exe in /nix/store" >&2
            return 1
        fi
    fi
}

# 通知を送る汎用関数（wsl-notify-send.exe を直接使用）
notify() {
    local title="${1:-通知}"
    local message="${2:-}"
    
    if ! check_notify_send; then
        return 1
    fi
    
    # デバッグ出力（必要に応じて有効化）
    if [[ "${NOTIFY_DEBUG:-}" == "true" ]]; then
        echo "[DEBUG] WSL_NOTIFY_SEND_EXE: $WSL_NOTIFY_SEND_EXE" >&2
        echo "[DEBUG] Title: $title" >&2
        echo "[DEBUG] Message: $message" >&2
    fi
    
    # 日本語を含む場合の対策
    # 方法1: 環境変数でUTF-8を明示
    local notification_text
    if [[ -n "$message" ]]; then
        notification_text=$(printf '%s\n%s' "$title" "$message")
    else
        notification_text="$title"
    fi
    
    # UTF-8エンコーディングを強制して実行
    LC_ALL=C.UTF-8 "$WSL_NOTIFY_SEND_EXE" --category "${WSL_DISTRO_NAME:-NixOS}" "$notification_text"
}

# 日本語対応版の通知関数（エスケープ処理あり）
notify_ja() {
    local title="${1:-通知}"
    local message="${2:-}"
    
    if ! check_notify_send; then
        return 1
    fi
    
    # 日本語をエスケープまたは英語に置換
    local safe_text
    if [[ -n "$message" ]]; then
        # 改行で区切るが、日本語は避ける
        safe_text="$title - $message"
    else
        safe_text="$title"
    fi
    
    "$WSL_NOTIFY_SEND_EXE" --category "${WSL_DISTRO_NAME:-NixOS}" "$safe_text"
}

# 絵文字を使った通知（日本語を避ける）
notify_emoji() {
    local type="${1:-info}"
    local title="${2:-Notification}"
    local message="${3:-}"
    
    local emoji
    case "$type" in
        success) emoji="✅" ;;
        error)   emoji="❌" ;;
        warning) emoji="⚠️" ;;
        info)    emoji="ℹ️" ;;
        *)       emoji="📢" ;;
    esac
    
    if [[ -n "$message" ]]; then
        notify "$emoji $title" "$message"
    else
        notify "$emoji $title"
    fi
}

# タイトルとメッセージを別々に扱う通知
notify_structured() {
    local title="${1:-通知}"
    local message="${2:-}"
    
    if ! check_notify_send; then
        return 1
    fi
    
    # 改行で区切って送信
    if [[ -n "$message" ]]; then
        notify-send "$(printf '%s\n%s' "$title" "$message")"
    else
        notify-send "$title"
    fi
}

# アイコン付き通知（wsl-notify-sendは --icon オプションをサポート）
notify_with_icon() {
    local title="${1:-通知}"
    local message="${2:-}"
    local icon="${3:-}"
    
    if ! check_notify_send; then
        return 1
    fi
    
    # 直接 wsl-notify-send.exe を呼び出す必要がある場合
    local wsl_notify_exe=$(which notify-send | grep -oP '/nix/store/[^/]+/bin/wsl-notify-send\.exe')
    
    if [[ -n "$icon" ]] && [[ -f "$icon" ]] && [[ -n "$wsl_notify_exe" ]]; then
        local win_icon=$(wslpath -w "$icon" 2>/dev/null)
        if [[ -n "$win_icon" ]]; then
            "$wsl_notify_exe" --icon "$win_icon" "$title: $message"
        else
            notify "$title" "$message"
        fi
    else
        notify "$title" "$message"
    fi
}

# カテゴリ別通知（英語版）
notify_info() {
    notify_emoji "info" "${1:-Info}" "$2"
}

notify_success() {
    notify_emoji "success" "${1:-Success}" "$2"
}

notify_warning() {
    notify_emoji "warning" "${1:-Warning}" "$2"
}

notify_error() {
    notify_emoji "error" "${1:-Error}" "$2"
}

# 日本語タイトルを英語に変換する関数
translate_title() {
    local title="$1"
    case "$title" in
        "ビルド完了"|"ビルド成功") echo "Build Complete" ;;
        "ビルド失敗") echo "Build Failed" ;;
        "テスト完了"|"テスト成功") echo "Test Complete" ;;
        "テスト失敗") echo "Test Failed" ;;
        "エラー"|"エラー発生") echo "Error" ;;
        "警告") echo "Warning" ;;
        "成功"|"完了") echo "Success" ;;
        "情報"|"お知らせ") echo "Info" ;;
        "ダウンロード完了") echo "Download Complete" ;;
        "アップロード完了") echo "Upload Complete" ;;
        "デプロイ完了") echo "Deploy Complete" ;;
        "処理完了") echo "Process Complete" ;;
        *) echo "$title" ;;  # 変換できない場合はそのまま
    esac
}

# 日本語メッセージを英語に変換する関数
translate_message() {
    local message="$1"
    case "$message" in
        *"成功しました"*) echo "Completed successfully" ;;
        *"失敗しました"*) echo "Failed" ;;
        *"完了しました"*) echo "Completed" ;;
        *"エラーが発生"*) echo "An error occurred" ;;
        *"正常に"*) echo "Successfully" ;;
        *) echo "$message" ;;  # 変換できない場合はそのまま
    esac
}

# 自動翻訳機能付き通知
notify_auto() {
    local title="${1:-Notification}"
    local message="${2:-}"
    
    # 日本語が含まれているかチェック
    if echo "$title$message" | grep -q '[ぁ-んァ-ヶー一-龠]'; then
        # 日本語が含まれている場合は英語に変換
        title=$(translate_title "$title")
        message=$(translate_message "$message")
    fi
    
    notify "$title" "$message"
}

# コマンド実行後に通知（改良版）
notify_after() {
    "$@"
    local exit_code=$?
    local cmd_name="$1"
    
    if [[ $exit_code -eq 0 ]]; then
        notify_success "$cmd_name" "completed successfully"
    else
        notify_error "$cmd_name" "failed with exit code: $exit_code"
    fi
    
    return $exit_code
}

# 長時間実行後に通知
long_task_notify() {
    local start_time=$(date +%s)
    local cmd_name="$1"
    
    "$@"
    local exit_code=$?
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # 10秒以上かかった場合のみ通知
    if [[ $duration -gt 10 ]]; then
        local duration_str=""
        if [[ $duration -gt 3600 ]]; then
            duration_str="$((duration / 3600))時間$((duration % 3600 / 60))分"
        elif [[ $duration -gt 60 ]]; then
            duration_str="$((duration / 60))分$((duration % 60))秒"
        else
            duration_str="${duration}秒"
        fi
        
        if [[ $exit_code -eq 0 ]]; then
            notify_success "タスク完了" "$cmd_name (実行時間: $duration_str)"
        else
            notify_error "タスク失敗" "$cmd_name (実行時間: $duration_str)"
        fi
    fi
    
    return $exit_code
}

# プログレス通知（進捗を定期的に通知）
notify_progress() {
    local task_name="${1:-タスク}"
    local total="${2:-100}"
    local current="${3:-0}"
    
    local percentage=$((current * 100 / total))
    notify "🔄 $task_name" "進捗: $percentage% ($current/$total)"
}

# デバッグ情報
debug_info() {
    echo "=== WSL Notify Debug Info ==="
    echo "WSL_NOTIFY_SEND_EXE: ${WSL_NOTIFY_SEND_EXE:-Not set}"
    
    if [[ -n "$WSL_NOTIFY_SEND_EXE" ]]; then
        echo "Executable exists: $([[ -x "$WSL_NOTIFY_SEND_EXE" ]] && echo 'Yes' || echo 'No')"
        if [[ -x "$WSL_NOTIFY_SEND_EXE" ]]; then
            echo "File info: $(ls -la "$WSL_NOTIFY_SEND_EXE")"
        fi
    fi
    
    echo ""
    echo "WSL_DISTRO_NAME: ${WSL_DISTRO_NAME:-Not set}"
    echo ""
    echo "Finding wsl-notify-send.exe in Nix store:"
    find /nix/store -maxdepth 3 -name "wsl-notify-send.exe" -type f 2>/dev/null | head -5
}

# テスト関数
test_notifications() {
    echo "Testing various notification types..."
    
    echo "1. Basic notification (single argument)"
    notify "Basic notification test."
    sleep 2
    
    echo "2. Title only"
    notify "Title only"
    sleep 2
    
    echo "3. Title with message"
    notify "Title" "This is a message."
    sleep 2
    
    echo "4. Direct exe call"
    "$WSL_NOTIFY_SEND_EXE" --category "NixOS" "Direct run test."
    sleep 2
    
    echo "5. Direct exe with newline"
    "$WSL_NOTIFY_SEND_EXE" --category "NixOS" "$(printf 'Title\nMessage')"
    sleep 2
    
    echo ""
    echo "All tests completed!"
}

# メイン処理
if [[ "${BASH_SOURCE[0]}" == "${0}" ]] || [[ "${(%):-%N}" == "${0}" ]]; then
    case "${1:-}" in
        info|success|warning|error)
            cmd=$1
            shift
            notify_$cmd "$@"
            ;;
        after)
            shift
            notify_after "$@"
            ;;
        long)
            shift
            long_task_notify "$@"
            ;;
        progress)
            shift
            notify_progress "$@"
            ;;
        debug)
            debug_info
            ;;
        test)
            test_notifications
            ;;
        help)
            echo "Usage: $0 [command] [arguments]"
            echo ""
            echo "Commands:"
            echo "  (none)        Send a basic notification"
            echo "  info          Send info notification with ℹ️"
            echo "  success       Send success notification with ✅"
            echo "  warning       Send warning notification with ⚠️"
            echo "  error         Send error notification with ❌"
            echo "  after         Execute command and notify when done"
            echo "  long          Execute command and notify if it takes >10s"
            echo "  progress      Send progress notification"
            echo "  debug         Show debug information"
            echo "  test          Test all notification types"
            echo "  help          Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 'ビルド完了'"
            echo "  $0 success 'デプロイ成功' 'アプリケーションがデプロイされました'"
            echo "  $0 after nix-build"
            echo "  $0 long make -j8"
            echo "  $0 progress 'ダウンロード' 100 45"
            ;;
        *)
            notify "$@"
            ;;
    esac
fi
