-- 分割した設定ファイルを読み込む
-- プラグインと設定ファイルの読み込み順を間違えるとエラーになるので、
-- 読み込み順は適宜調整している。
require('setting/keymapping')
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

-- require("lazy").setup("plugins")
require("lazy").setup({
  dev = {
    path = "~/my_neovim_plugins",
    patterns = { 'extend_word_motion.nvim', 'ft_mapper.nvim' },
  },
  spec = {
    import = 'plugins',
  }
})

-- 分割した設定ファイルを読み込む
require('setting.colorscheme')
require('setting.basic')
require('setting.lexima')
require('setting.pum')
require('setting.ddc')
require('setting.skkeleton')
require('setting.clipboard')
require('setting.nvim-keycastr')
