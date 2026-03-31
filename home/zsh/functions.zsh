# functions.zsh - Custom shell functions

# WSL notify-send wrapper (uses Nix-provided WSL_NOTIFY_SEND env var)
notify-send() {
  if [[ -n "$WSL_NOTIFY_SEND" ]]; then
    "$WSL_NOTIFY_SEND" --category "$WSL_DISTRO_NAME" "$@"
  else
    echo "Error: WSL_NOTIFY_SEND not set" >&2
    return 1
  fi
}

# run-help functions
autoload -Uz run-help run-help-git run-help-ip run-help-sudo

# Shell integration for prompt marking
precmd() {
  # Mark end of previous command (no exit code here, since Zsh lacks easy last status in prompt):
  print -P "\e]133;D;\a"
}
PROMPT=$'%{\e]133;A\a%}'$PROMPT$'%{\e]133;B\a%}'

# ghq 
ghq-fzf-cd() {
  local selected_dir=$(ghq list --full-path | fzf --prompt="Repository> ")
  if [ -n "$selected_dir" ];
  then
    # ZLE のバッファの内容を "cd ${selected_dir}" に置き換える
    BUFFER="cd ${selected_dir}"
    zle accept-line
    zle clear-screen
  else
    zle redisplay
  fi
}

zle -N ghq-fzf-cd
