vim.opt.clipboard:append { "unnamedplus" }

-- copy to clipboard
vim.keymap.set('v', '<leader>y', '"+y')
vim.keymap.set('n', '<leader>Y', '"+yg_')
vim.keymap.set('n', '<leader>y', '"+y')

-- C-xでコマンドラインに入力した文字列をヤンクする
vim.keymap.set('c', '<C-x>', function()
  vim.fn.setreg('"0', vim.fn.getcmdline())
end)

local function paste()
  return {
    vim.fn.split(vim.fn.getreg(""), "\n"),
    vim.fn.getregtype(""),
  }
end

vim.g.clipboard = {
  name = "OSC 52",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = {
    ['+'] = paste,
    ['*'] = paste
  },
}
