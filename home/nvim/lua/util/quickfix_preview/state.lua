--- quickfix_preview の状態管理モジュール.
-- @module quickfix_preview.state

local M = {}

-- プライベートな状態
local state = {
  preview_win = nil,
  preview_buf = nil,
  display_preview = false,
  closing_preview = false,
  source = 'grep' -- 'grep', 'find', 'buffers' など
}

--- 状態を取得.
-- @return table 現在の状態
function M.get()
  return state
end

--- プレビューウィンドウを設定.
-- @param win number|nil ウィンドウID
function M.set_preview_win(win)
  state.preview_win = win
end

--- プレビューバッファを設定.
-- @param buf number|nil バッファID
function M.set_preview_buf(buf)
  state.preview_buf = buf
end

--- プレビュー表示状態を設定.
-- @param display boolean 表示するかどうか
function M.set_display_preview(display)
  state.display_preview = display
end

--- クローズ中フラグを設定.
-- @param closing boolean クローズ中かどうか
function M.set_closing_preview(closing)
  state.closing_preview = closing
end

--- ソースを設定.
-- @param source string ソースの種類（'grep', 'find', 'buffers'）
function M.set_source(source)
  state.source = source
end

--- find/fd から開かれたかどうかを判定.
-- @return boolean find/fdから開かれた場合はtrue
function M.is_from_find()
  return state.source == 'find'
end

--- 状態をリセット.
function M.reset()
  state.preview_win = nil
  state.preview_buf = nil
  state.display_preview = false
  state.closing_preview = false
  state.source = 'grep'
end

return M