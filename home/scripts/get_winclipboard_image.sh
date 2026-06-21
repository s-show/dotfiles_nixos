#!/usr/bin/env bash

# デフォルトの保存先 ($HOMEを使ってユーザー名を自動解決)
DATETIME=$(date +'%Y%m%d_%H%M')
OUTPUT_FILE="${1:-$HOME/.cache/${DATETIME}_clipboard_image.png}"
OUTPUT_DIR=$(dirname "$OUTPUT_FILE")
mkdir -p "$OUTPUT_DIR"

# PowerShellコマンド: クリップボード画像をWindowsのTempに保存
PS_COMMAND=' 
try { 
    Add-Type -AssemblyName System.Windows.Forms
    if ([System.Windows.Forms.Clipboard]::ContainsImage()) {
        $image = [System.Windows.Forms.Clipboard]::GetImage()
        $tempPath = [System.IO.Path]::GetTempFileName()
        $imagePath = $tempPath + ".png"
        $image.Save($imagePath, [System.Drawing.Imaging.ImageFormat]::Png)
        Remove-Item $tempPath
        Write-Output $imagePath
        exit 0
    } else {
        exit 1
    }
} catch {
    exit 1
}
'

# PowerShellを実行してパスを取得
WIN_TEMP_PATH=$(/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "$PS_COMMAND" | tr -d '\r')

# エラーチェック
if [ $? -ne 0 ] || [ -z "$WIN_TEMP_PATH" ]; then
    echo "Error: No image found."
    exit 1
fi

# WSLパスに変換して移動
WSL_TEMP_PATH=$(wslpath -u "$WIN_TEMP_PATH")
if [ -f "$WSL_TEMP_PATH" ]; then
    mv "$WSL_TEMP_PATH" "$OUTPUT_FILE"
    echo "Image saved to: $OUTPUT_FILE"
else
    echo "Error: File not found."
    exit 1
fi
