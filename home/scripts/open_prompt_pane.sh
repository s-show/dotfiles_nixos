# 分割前に元ペインと現在のウィンドウの情報を保存
# 末尾の改行は思わぬ挙動に繋がりかねないので削除しておく
src_pane=$(tmux display-message -p '#{pane_index}' | tr -d "\n\t")
current_win=$(tmux display-message -p '#{window_index}' | tr -d "\n\t")

# 分割して新ペインの情報を取得
new_pane=$(tmux split-window -P -p 25 -F '#{window_index}.#{pane_index}' 'nvim_ime')

# 分割元と分割したペインの情報を一時ファイルに保存する
# 複数ウィンドウに対応するため、一時ファイルのファイル名を現在のウィンドウ番号と関連付ける。
echo "${src_pane}" > /tmp/src_pane_"${current_win}"
echo "${new_pane}" > /tmp/new_pane_"${current_win}"
