#!/usr/bin/env zsh

echo "=== Environment Debug ==="
echo "Shell: $SHELL"
echo "PATH: $PATH"
echo ""

echo "=== notify-send check ==="
echo "command -v notify-send:"
command -v notify-send
echo "Exit code: $?"
echo ""

echo "type notify-send:"
type notify-send
echo ""

echo "which notify-send:"
which notify-send 2>&1
echo ""

echo "=== Finding wsl-notify-send.exe ==="
echo "In Nix store:"
ls /nix/store/*/bin/wsl-notify-send.exe 2>/dev/null | head -5
echo ""

echo "In profile:"
ls -la ~/.nix-profile/bin/wsl-notify-send* 2>/dev/null
echo ""

echo "=== Function test ==="
check_test() {
    echo "Inside function - command -v notify-send:"
    command -v notify-send
    echo "Exit code: $?"
}
check_test
