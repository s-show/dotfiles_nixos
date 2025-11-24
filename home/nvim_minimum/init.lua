local plugin_paths = {
  "/home/s-show/.local/share/nvim/lazy/denops.vim",
  "/home/s-show/.local/share/nvim/lazy/skkeleton",
  "/home/s-show/.local/share/nvim/lazy/blink.cmp",
  -- "/home/s-show/.local/share/nvim/lazy/blink-cmp-skkeleton",
  "/home/s-show/my_neovim_plugins/blink-cmp-skkeleton/"
}

for _, path in ipairs(plugin_paths) do
  vim.opt.runtimepath:append(path)
end

require('blink.cmp').setup({
  keymap = {
    preset = "super-tab",
    ["<Space>"] = {},
  },
  sources = {
    default = function(ctx)
      if require("blink-cmp-skkeleton").is_enabled() then
        return { "skkeleton" }
      else
        return { "lsp", "path", "snippets", "buffer", "cmdline" }
      end
    end,
    providers = {
      skkeleton = {
        name = "skkeleton",
        module = "blink-cmp-skkeleton",
      },
    },
    -- min_keyword_length = function(ctx)
    --   -- :wq, :qa -> menu doesn't popup
    --   -- :Lazy, :wqa -> menu popup
    --   if ctx.mode == "cmdline" and ctx.line:find("^%l+$") ~= nil then
    --     return 3
    --   end
    --   return 0
    -- end,
  },
})
require('setting.skkeleton')
vim.g.blink_cmp_skkeleton_debug = false
