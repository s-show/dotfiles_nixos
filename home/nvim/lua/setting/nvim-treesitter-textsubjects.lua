require('nvim-treesitter.configs').setup {
  textsubjects = {
    enable = true,
    -- prev_selection = ',',     -- (Optional) keymap to select the previous selection
    keymaps = {
      ['.'] = 'textsubjects-smart',
      ['go'] = 'textsubjects-container-outer',
      ['gi'] = { 'textsubjects-container-inner', desc = "Select inside containers (classes, functions, etc.)" },
    },
  },
}
