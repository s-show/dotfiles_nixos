-- 分割した設定ファイルを読み込む
-- プラグインと設定ファイルの読み込み順を間違えるとエラーになるので、
-- 読み込み順は適宜調整している。
require('setting/keymapping')
require('setting.ftjpn')
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
    patterns = { 'extend_word_motion.nvim' },
  },
  spec = {
    import = 'plugins',
  }
})

-- 分割した設定ファイルを読み込む
require('setting.colorscheme')
require('setting.lualine')
require('setting.basic')
require('lsp.init')
require('setting.lexima')
require('setting.pum')
require('setting.ddc')
-- require('setting.nvim-cmp')
-- require('setting.blink-cmp')
require('setting.ddu')
require('setting.skkeleton')
require('setting.clipboard')
require('setting.chowcho-nvim')
require('setting.denops-signature_help')
require('setting.nvim-treesitter')
require('setting.nvim-treesitter-textsubjects')
require('setting.oil-nvim')
require('setting.tinysegmenter-nvim')
require('setting.denops-popup-preview-vim')
require('setting.aerial-nvim')
require('setting.nvim-colorizer')
require('setting.codecompanion-nvim')
require('setting.snacks-nvim')
