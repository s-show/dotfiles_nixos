return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    bigfile = { enabled = false },
    dashboard = {
      enabled = true,
      width = 54,
      row = nil,
      col = nil,
      pane_gap = 5,
      sections = {
        {
          section = 'header',
          align = 'center',
          enabled = function()
            return not (vim.o.columns > 130)
          end,
        },
        {
          pane = 1,
          {
            enabled = function()
              return vim.o.columns > 130
            end,
            section = 'terminal',
            cmd =
            'chafa /home/s-show/.dotfiles/nvim/dashboard_logo_500x500.png --size 48 -c full --symbols vhalf; sleep .1',
            height = 48,
            -- width = 36,
            padding = 1,
          },
          -- {
          --   section = 'startup',
          --   padding = 1,
          --   enabled = function()
          --     return vim.o.columns > 130
          --   end,
          -- },
        },
        {
          pane = 2,
          { section = 'keys', padding = 1, gap = 0 },
          {
            icon = ' ',
            title = 'Recent Files',
          },
          {
            section = 'recent_files',
            opts = { limit = 3 },
            indent = 2,
            padding = 1,
          },
          {
            icon = ' ',
            title = 'Projects',
          },
          {
            section = 'projects',
            opts = { limit = 3 },
            indent = 2,
            padding = 1,
          },
          {
            section = 'startup',
            padding = 1,
            enabled = function()
              return not (vim.o.columns > 130)
            end,
          },
        },
      },
    },
    explorer = { enabled = true },
    indent = { enabled = false },
    input = { enabled = false },
    picker = { enabled = true },
    notifier = { enabled = false },
    quickfile = { enabled = false },
    scope = { enabled = false },
    scroll = { enabled = false },
    statuscolumn = { enabled = false },
    words = { enabled = false },
  },
  -- config = function(_, opts)
  --   require('snacks').setup(opts)
  -- end
}
