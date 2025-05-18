return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  opts = {
    adapters = {
      openrouter = function()
        return require('codecompanion.adapters').extend('openai_compatible', {
          name = 'openrouter',
          env = {
            url = 'https://openrouter.ai/api',
            api_key = vim.env.OPENROUTER_API_KEY,
            -- chat_url = '/v1/chat/completions',
          },
          scheme = {
            model = {
              default = 'anthropic/claude-3.7-sonnet',
            },
          },
        })
      end
    },
    strategies = {
      chat = {
        adapter = 'openrouter',
        slash_commands = {
          ["buffer"] = {
            callback = "strategies.chat.slash_commands.buffer",
            opts = {
              provider = "snacks",
              contains_code = true,
            },
          },
          ["file"] = {
            callback = "strategies.chat.slash_commands.file",
            opts = {
              provider = "snacks",
              contains_code = true,
            },
          },
          ["help"] = {
            opts = {
              provider = "snacks",
            },
          },
          ["symbols"] = {
            opts = {
              provider = "snacks",
            },
          },
          ["workspace"] = {
            opts = {
              provider = "snacks",
            },
          },
        },
      },
      inline = {
        adapter = 'openrouter',
      },
      agent = {
        adapter = 'openrouter',
      },
      opts = {
        language = 'Japanese',
      },
    },
    log_level = 'TRACE',
    display = {
      action_palette = {
        width = 95,
        height = 10,
        prompt = 'prompt',
        provider = 'default',
        opts = {
          show_default_actions = true,
          show_default_prompt_library = true,
        },
      },
      chat = {
        window = {
          position = 'right',
        },
      }
    },
  },
  cmd = {
    "CodeCompanion",
    "CodeCompanionActions",
    "CodeCompanionChat",
    "CodeCompanionCmd",
    "CodeCompanionLoad",
  },
  keys = {
    { "<Space>cc", "<Cmd>CodeCompanionChat Toggle<CR>", mode = { "n" } },
    { "<Space>cc", "<Cmd>CodeCompanionChat<CR>",        mode = { "v" } },
    { "<Space>ca", "<Cmd>CodeCompanionActions<CR>",     mode = { "n", "x" } },
  },
}
