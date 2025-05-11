return {
  {
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPre", "BufNewFile" },
    -- event = { "UIEnter" },
    config = function()
      require("hlchunk").setup({
        chunk = {
          enable = true,
          use_treesitter = true,
          -- notify = true,
          chars = {
            horizontal_line = "─",
            vertical_line = "│",
            left_top = "╭",
            left_bottom = "╰",
            right_arrow = ">",
          },
          -- style = "#edea82",
          -- style = "#ffffff",
          style = "#4682b4",
          support_filetypes = {
            "*.vim",
            "*.md",
            "*.ts",
            "*.js",
            "*.yml",
            "*.html",
            "*.lua",
          },
        },
        indent = {
          enable = true,
          use_treesitter = false,
          chars = {
            "┃",
            "│",
            "┊",
            "┆",
            "¦",
            ";",
          },
          style = {
              -- "#F5F5F5",
              -- "#FFFFe0",
              -- "#FFFF00",
              -- "#DAA520",
              -- "#FFA500",
              -- "#00FFFF",
              -- "#0000FF
              "#4682b4"
          },
        },
        line_num = {
          enable = false;
        },
        blank = {
          enable = false,
          --[[ chars = {
                  "․",
                  "⁚",
                  "⁖",
                  "⁘",
                  "⁙",
          },
          style = {
              "#666666",
              "#555555",
              "#444444",
          }, ]]
        }
      })
    end
  }
}
