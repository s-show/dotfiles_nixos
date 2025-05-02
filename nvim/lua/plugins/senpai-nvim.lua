return {
  {
    "eetann/senpai.nvim",
    build = "bun install --frozen-lockfile",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      { "<space>qs", "<Cmd>Senpai toggleChat<CR>" },
      { "<space>ql", "<Cmd>Senpai promptLauncher<CR>" },
      { "<space>qv", "<Cmd>Senpai transferToChat<CR>", mode = "v" },
    },
    cmd = { "Senpai" },
    opts = {
      providers = {
        default = "openai",
        -- openai = { model_id = "openai/gpt-4o" },
      },
      debug = true,
    }
  }
}
