return {
  "mfussenegger/nvim-dap",
  dependencies = {
    {
      "igorlfs/nvim-dap-view",
      opts = {
        auto_toggle = true,
        winbar = {
          sections = {
            "console",
            "watches",
            "scopes",
            "exceptions",
            "breakpoints",
            "threads",
            "repl",
          },
          controls = {
            enabled = true,
            position = "left", -- ボタンの配置位置 ("left"|"right")
          },
        },
      },
    },
    "nvim-neotest/nvim-nio",
    {
      "theHamsta/nvim-dap-virtual-text",
      opts = {},
    },
  },
  lazy = true
}
