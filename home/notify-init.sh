#!/usr/bin/env zsh

# PowerShellのパスを定義
POWERSHELL_WIN_PATH="C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"
POWERSHELL_WSL_PATH="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"

# PowerShellを実行する関数
run_powershell() {
    local command="$1"
    
    # 方法1: /init を使用
    if [[ -x /init ]]; then
        /init "$POWERSHELL_WSL_PATH" -NoProfile -ExecutionPolicy Bypass -Command "$command" 2>&1
        return $?
    fi
    
    # 方法2: 直接実行を試みる
    if [[ -x "$POWERSHELL_WSL_PATH" ]]; then
        "$POWERSHELL_WSL_PATH" -NoProfile -ExecutionPolicy Bypass -Command "$command" 2>&1
        return $?
    fi
    
    echo "Error: Cannot execute PowerShell" >&2
    return 1
}

# シンプルな通知（メッセージボックス）
simple_notify() {
    local title="${1:-通知}"
    local message="${2:-メッセージ}"
    
    run_powershell "
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show('$message', '$title', 'OK', 'Information')
    "
}

# バルーン通知
balloon_notify() {
    local title="${1:-通知}"
    local message="${2:-メッセージ}"
    
    run_powershell "
        Add-Type -AssemblyName System.Windows.Forms
        \$notification = New-Object System.Windows.Forms.NotifyIcon
        \$path = Get-Process -Id \$PID | Select-Object -ExpandProperty Path
        \$notification.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon(\$path)
        \$notification.BalloonTipIcon = 'Info'
        \$notification.BalloonTipTitle = '$title'
        \$notification.BalloonTipText = '$message'
        \$notification.Visible = \$true
        \$notification.ShowBalloonTip(5000)
        Start-Sleep -Seconds 6
        \$notification.Dispose()
    "
}

# PowerShellスクリプトファイルを作成して実行する方法
file_based_notify() {
    local title="${1:-通知}"
    local message="${2:-メッセージ}"
    
    # 一時ファイルを作成
    local temp_script="/tmp/notify_$$.ps1"
    
    cat > "$temp_script" << 'EOF'
param($Title, $Message)

Add-Type -AssemblyName System.Windows.Forms
$notification = New-Object System.Windows.Forms.NotifyIcon
$path = Get-Process -Id $PID | Select-Object -ExpandProperty Path
$notification.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$notification.BalloonTipIcon = 'Info'
$notification.BalloonTipTitle = $Title
$notification.BalloonTipText = $Message
$notification.Visible = $true
$notification.ShowBalloonTip(5000)
Start-Sleep -Seconds 6
$notification.Dispose()
EOF
    
    # Windowsパスに変換
    local win_script_path=$(wslpath -w "$temp_script" 2>/dev/null || echo "C:\\tmp\\notify_$$.ps1")
    
    # /init で実行
    if [[ -x /init ]]; then
        /init "$POWERSHELL_WSL_PATH" -NoProfile -ExecutionPolicy Bypass -File "$win_script_path" -Title "$title" -Message "$message"
        local result=$?
    else
        echo "Error: /init not found" >&2
        local result=1
    fi
    
    # 一時ファイルを削除
    rm -f "$temp_script"
    
    return $result
}

# VBScriptを使った通知（最終手段）
vbs_notify() {
    local title="${1:-通知}"
    local message="${2:-メッセージ}"
    
    # VBScriptファイルを作成
    local temp_vbs="/tmp/notify_$$.vbs"
    
    cat > "$temp_vbs" << EOF
MsgBox "$message", 64, "$title"
EOF
    
    # wscript.exe で実行
    if [[ -x /init ]]; then
        /init /mnt/c/Windows/System32/wscript.exe "$temp_vbs"
        local result=$?
    else
        echo "Error: Cannot execute VBScript" >&2
        local result=1
    fi
    
    # 一時ファイルを削除
    rm -f "$temp_vbs"
    
    return $result
}

# デバッグ情報
debug_info() {
    echo "=== WSL Notify Debug Info ==="
    echo "WSL2 Detected: $(grep -q microsoft /proc/version && echo 'Yes' || echo 'No')"
    echo "/init exists: $([[ -x /init ]] && echo 'Yes' || echo 'No')"
    echo "PowerShell path exists: $([[ -e $POWERSHELL_WSL_PATH ]] && echo 'Yes' || echo 'No')"
    echo ""
    echo "Testing /init execution:"
    /init /mnt/c/Windows/System32/cmd.exe /c "echo Hello from Windows" 2>&1
    echo ""
    echo "WSL configuration:"
    cat /etc/wsl.conf 2>/dev/null || echo "No /etc/wsl.conf found"
}

# メイン処理
case "${1:-}" in
    simple)
        shift
        simple_notify "$@"
        ;;
    balloon)
        shift
        balloon_notify "$@"
        ;;
    file)
        shift
        file_based_notify "$@"
        ;;
    vbs)
        shift
        vbs_notify "$@"
        ;;
    debug)
        debug_info
        ;;
    test)
        echo "Testing notification methods..."
        echo ""
        echo "1. VBScript method:"
        vbs_notify "VBScript Test" "This should work even with interop issues"
        echo "Exit code: $?"
        ;;
    *)
        echo "Usage: $0 [method] [title] [message]"
        echo ""
        echo "Methods:"
        echo "  simple   - Simple MessageBox"
        echo "  balloon  - Balloon notification"
        echo "  file     - File-based PowerShell"
        echo "  vbs      - VBScript (most compatible)"
        echo "  debug    - Show debug information"
        echo "  test     - Test working methods"
        ;;
esac
