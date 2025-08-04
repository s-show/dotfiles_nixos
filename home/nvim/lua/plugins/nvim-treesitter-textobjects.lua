return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  lazy = true,
  config = function()
    require("nvim-treesitter.configs").setup({
      textobjects = {
        select = {
          enable = true,
          -- Automatically jump forward to textobj, similar to targets.vim
          lookahead = true,
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ["af"] = {
              query = "@function.outer",
              desc = "Select outer part of a method/function definition",
            },
            ["if"] = {
              query = "@function.inner",
              desc = "Select inner part of a method/function definition",
            },
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["ia"] = "@parameter.inner",
            ["ai"] = "@conditional.outer",
            ["ii"] = "@conditional.inner",
          },
        },
      },
    })
  end,
}
