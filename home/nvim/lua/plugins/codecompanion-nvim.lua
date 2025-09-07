return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  opts = {
    adapters = {
      cerebras = function()
        return require("codecompanion.adapters").extend("openai_compatible", {
          env = {
            url = "https://api.cerebras.ai",
            api_key = os.getenv("CEREBRAS_API_KEY"),
            chat_url = "/v1/chat/completions",
            models_endpoint = "/v1/models",
          },
          schema = {
            model = {
              default = "gpt-oss-120b",
            },
          },
        })
      end,
    },
    strategies = {
      chat = {
        adapter = 'cerebras',
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
        adapter = 'cerebras',
      },
      agent = {
        adapter = 'cerebras',
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
    language = "Japanese",
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
