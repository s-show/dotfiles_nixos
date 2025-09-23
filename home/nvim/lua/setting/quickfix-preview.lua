--- 全体的な設定.
-- この設定全体で使う設定など.
-- @section basic

-- Wildmenu設定
vim.opt.wildmenu = true
vim.opt.wildmode = { 'noselect:longest:lastused', 'full' }

-- quickfix_preview モジュールを使用
local quickfix_preview = require('util.quickfix_preview')

-- セットアップを実行
quickfix_preview.setup({
  debug_mode = false
})