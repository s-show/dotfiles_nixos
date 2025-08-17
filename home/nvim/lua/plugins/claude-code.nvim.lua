return {
  "greggh/claude-code.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim", -- Required for git operations
  },
  config = function()
    require("claude-code").setup({
      window = {
        position = 'vertical'
      },
      keymaps = {
        window_navigation = false,
        scrolling = false,
      },
      command_variants = {
        -- custom debug variant
        debug = "--debug --verbose",
      },
    })
  end
}
