vim.filetype.add({ extension = { ejs = "ejs" } })
vim.treesitter.language.register("html", "ejs")

-- nvim-treesitter main ブランチの設定
-- (main ブランチでは ensure_installed, highlight.enable 等は廃止)
require('nvim-treesitter').setup {
  install_dir = vim.fn.stdpath('data') .. '/site',
}

-- nvim-treesitter main ブランチの lua クエリ/パーサーバージョン不一致への対処
-- 現在の lua.so は `operand` フィールド (旧文法) を使用しているが、
-- クエリは `operator: _ @operator` (新文法) を要求するためエラーが発生する。
-- 問題のパターンをクエリから除去して回避する。
-- 注: この設定ファイルは lazy.setup() 後に読み込まれるため LazyDone は使わず直接実行する。
vim.schedule(function()
  local query_file = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/runtime/queries/lua/highlights.scm"
  local f = io.open(query_file, "r")
  if not f then return end
  local content = f:read("*a")
  f:close()
  -- operator: フィールドを使うパターンを除去 (インストール済みパーサーが未対応)
  content = content:gsub("%(binary_expression%s*\n%s*operator: _ @operator%)", "")
  content = content:gsub("%(unary_expression%s*\n%s*operator: _ @operator%)", "")
  pcall(vim.treesitter.query.set, "lua", "highlights", content)
end)
