local M = {}

--- テキストが空白文字だけで構成されているか調べる関数.
-- @param text string 調べたいテキスト.
-- @return boolean 空白文字だけなら `true`, 非空白文字があれば `false` を返す
function M.is_blank_text(text)
  if text == nil or #text == 0 or vim.fn.match(text, '\\S') == -1 then
    return true
  else
    return false
  end
end

return M
