return {
  {
    "A7Lavinraj/fyler.nvim",
    dependencies = { "nvim-mini/mini.icons" },
    branch = "stable", -- Use stable branch for production
    lazy = false,      -- Necessary for `default_explorer` to work properly
    opts = {
      views = {
        finder = {
          mappings = {
            ["|"] = false,
            ["^"] = false,
            ["<c-s>"] = "SelectSplit",
            ["<c-v>"] = "SelectVSplit",
            ["-"] = "GotoParent",
            ---@param self Finder
            ---`self:~~~` の関数は、プラグインの内部関数を呼び出して使っているもの。
            ["<C-h>"] = function(self)
              local current_node = self:cursor_node_entry()
              local parent_ref_id = self.files:find_parent(current_node.ref_id)
              if not parent_ref_id then
                return
              end
              vim.print(self.files.trie.value)
              vim.print(parent_ref_id)
              if self.files.trie.value == parent_ref_id then
                self:exec_action("n_goto_parent")
              else
                self:exec_action("n_collapse_node")
              end
            end,
            ["<left>"] = function(self)
              local current_node = self:cursor_node_entry()
              local parent_ref_id = self.files:find_parent(current_node.ref_id)
              if not parent_ref_id then
                return
              end
              if self.files.trie.value == parent_ref_id then
                self:exec_action("n_goto_parent")
              else
                self:exec_action("n_collapse_node")
              end
            end,
            ["<right>"] = function (self)
              local current_node = self:cursor_node_entry()
              if not current_node then
                return
              end
              if current_node.type == 'directory' then
                self:exec_action("n_select")
              elseif current_node.type == 'file' then
                self:exec_action("n_select")
              else
                return
              end
            end,
            ["<C-p>"] = function (self)
              local current_node = self:cursor_node_entry()
              local stat = vim.uv.fs_stat(current_node.path)
              if not stat then
                return
              end
              if stat.size == 0 then
                vim.print("empty file.")
                return
              end
              local buf = vim.api.nvim_create_buf(false, true)
              local lines = vim.fn.readfile(current_node.path)
              vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

              -- fyler のフローティングウィンドウの情報を取得
              local current_win = vim.api.nvim_get_current_win()
              local win_config = vim.api.nvim_win_get_config(current_win)

              local opts = {
                relative = "editor",
                -- プレビュー画面は fyler のフローティングウィンドウの高さなどを基準に表示する
                width = math.floor(win_config.width / 2),
                height = math.floor(win_config.height),
                row = math.floor(win_config.row),
                col = math.floor(win_config.col + win_config.width / 2),
                border = "rounded"
              }
              vim.api.nvim_open_win(buf, true, opts)
              vim.keymap.set('n', 'q', '<cmd>close<CR>', {
                buffer = buf,
                silent = true,
                nowait = true,
              })
              vim.keymap.set('n', '<C-p>', '<cmd>close<CR>', {
                buffer = buf,
                silent = true,
                nowait = true,
              })
            end
          },
          win = {
            border = "rounded"
          },
          win_opts = {
            cursorline = true
          }
        }
      }
    },
    keys = {
      { "-", "<Cmd>Fyler kind=float<Cr>", desc = "Open Fyler View" },
    }
  }
}
