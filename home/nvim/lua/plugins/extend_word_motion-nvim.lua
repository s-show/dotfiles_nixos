return {
  -- dir = '~/my_neovim_plugins/extend_word_motion.nvim',
  's-show/extend_word_motion.nvim',
  dev = false,
  opts = {
    -- extend_motions = { 'w', 'b', 'e', 'ge', 'f' },
    -- extend_modes = { 'n', 'v', 'o', 'c' }
    debug = false
  },
  dependencies = {
    'sirasagi62/tinysegmenter.nvim'
  },
}
