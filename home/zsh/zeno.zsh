export ZENO_HOME=~/.config/zsh/zeno

# git file preview with color
export ZENO_GIT_CAT="bat --color=always"

# git folder preview with color
# export ZENO_GIT_TREE="eza --tree"

if [[ -n $ZENO_LOADED ]]; then
  bindkey ' '  zeno-auto-snippet

  # if you use zsh's incremental search
  # bindkey -M isearch ' ' self-insert
  bindkey '^m' zeno-auto-snippet-and-accept-line
  bindkey '^i' zeno-completion
  # open snippet picker (fzf) and insert at cursor
  bindkey '^xx' zeno-insert-snippet
  bindkey '^x '  zeno-insert-space
  bindkey '^x^m' accept-line
  bindkey '^x^z' zeno-toggle-auto-snippet
  # preprompt bindings
  bindkey '^xp' zeno-preprompt
  bindkey '^xs' zeno-preprompt-snippet
  # Outside ZLE you can run `zeno-preprompt git {{cmd}}` or `zeno-preprompt-snippet foo`
  # to set the next prompt prefix; invoking them with an empty argument resets the state.
  bindkey '^r' zeno-smart-history-selection # smart history widget

  # fallback if completion not matched
  # (default: fzf-completion if exists; otherwise expand-or-complete)
  # export ZENO_COMPLETION_FALLBACK=expand-or-complete
fi
