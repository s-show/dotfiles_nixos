# 分割前に元ペインの情報を保存
src_window=$(tmux display-message -p '#{window_index}')
src_pane=$(tmux display-message -p '#{pane_index}')

# 分割して新ペインの情報を取得
new_pane=$(tmux split-window -P -p 25 -F '#{window_index}.#{pane_index}' 'nvim_ime')

# 分割元と分割したペインの情報を一時ファイルに保存する
echo "${src_window}.${src_pane}" > /tmp/src_pane
echo "${src_window}.${new_pane}" > /tmp/new_pane
