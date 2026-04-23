src_window=$(tmux display-message -p '#{window_index}')

tmux resize-pane -x 75 -t "${src_window}.1"
