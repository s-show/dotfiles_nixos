-- 分割した設定ファイルを読み込む
-- プラグインと設定ファイルの読み込み順を間違えるとエラーになるので、
-- 読み込み順は適宜調整している。
require('setting.keymapping')
require('setting.user_interface')

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    import = 'plugins',
  }
})

-- 分割した設定ファイルを読み込む
require('setting.colorscheme')
require('setting.basic')
require('setting.clipboard')

-- 引数でファイルを渡してもノーマルモードで起動させるための設定
vim.api.nvim_create_autocmd("VimEnter", {
  pattern = "*.md",
  callback = function()
    vim.cmd('stopinsert')
  end,
})
