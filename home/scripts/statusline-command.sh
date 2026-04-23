#!/usr/bin/env bash

# Claude Code status line matching Starship nordfox palette configuration

# Read JSON input
input=$(cat)

# Extract workspace directory
workspace_dir=$(echo "$input" | jq -r '.workspace.current_dir')

# Change to workspace directory for git context
cd "$workspace_dir" 2>/dev/null || cd ~

# ANSI color helpers (nordfox palette approximations using 256-color codes)
# dir_bg=#a3be8c (green), dir_fg=#2e3440 (dark)
# git_bg=#ebcb8b (yellow), git_fg=#39404f (dark)
# username style: bold
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"

# nordfox colors approximated to nearest 256-color
# dir: bg=#a3be8c -> 150, fg=#2e3440 -> 236
DIR_BG="\033[48;5;150m"
DIR_FG="\033[38;5;236m"
# git: bg=#ebcb8b -> 222, fg=#39404f -> 237
GIT_BG="\033[48;5;222m"
GIT_FG="\033[38;5;237m"
# username: bold white-ish
USER_COLOR="\033[1;37m"
# time: dim/purple-ish (#b48ead -> 139)
TIME_COLOR="\033[38;5;139m"

# Build components
username=$(whoami)
current_dir=$(pwd | sed "s|^$HOME|~|")
time_str=$(date +"%R")

# Context window remaining (if available)
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# Get git info (skip locks for performance)
git_section=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -c core.useBuiltinFSMonitor=false -c core.fsmonitor= rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        if ! git -c core.useBuiltinFSMonitor=false -c core.fsmonitor= diff --quiet 2>/dev/null || \
           ! git -c core.useBuiltinFSMonitor=false -c core.fsmonitor= diff --cached --quiet 2>/dev/null; then
            status_indicator="*"
        else
            status_indicator=""
        fi
        git_section=$(printf "${GIT_BG}${GIT_FG}[${BOLD} %s%s${RESET}${GIT_BG}${GIT_FG}]${RESET}" "$branch" "$status_indicator")
    fi
fi

# Username section
user_section=$(printf "${USER_COLOR}[%s]${RESET}" "$username")

# Directory section
dir_section=$(printf "${DIR_BG}${DIR_FG}[  %s]${RESET}" "$current_dir")

# Time section
time_section=$(printf "${TIME_COLOR}[   %s ]${RESET}" "$time_str")

# Context window section (only shown when data is available)
ctx_section=""
if [ -n "$remaining" ]; then
    ctx_section=$(printf "${DIM}[ctx:%.0f%%]${RESET}" "$remaining")
fi

# Assemble the status line
printf "%s%s%s%s%s" "$user_section" "$dir_section" "$git_section" "$time_section" "$ctx_section"
