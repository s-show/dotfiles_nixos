#!/usr/bin/env bash

# Claude Code status line inspired by Starship prompt
# This script receives JSON input via stdin and generates a status line

# Read JSON input
input=$(cat)

# Extract workspace directory
workspace_dir=$(echo "$input" | jq -r '.workspace.current_dir')

# Change to workspace directory for git context
cd "$workspace_dir" 2>/dev/null || cd ~

# Build status line components
username=$(whoami)
current_dir=$(pwd | sed "s|^$HOME|~|")
time_str=$(date +"%R")

# Get git info (skip locks for performance)
git_info=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -c core.useBuiltinFSMonitor=false -c core.fsmonitor= rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        # Check for git status
        if ! git -c core.useBuiltinFSMonitor=false -c core.fsmonitor= diff --quiet 2>/dev/null || \
           ! git -c core.useBuiltinFSMonitor=false -c core.fsmonitor= diff --cached --quiet 2>/dev/null; then
            status_indicator="*"
        else
            status_indicator=""
        fi
        git_info="[git:$branch$status_indicator]"
    fi
fi

# Construct status line with colors similar to Starship nordfox palette
# Using printf for ANSI color codes
printf "[%s][%s][%s][   %s ]" \
    "$username" \
    "$current_dir" \
    "$git_info" \
    "$time_str"
