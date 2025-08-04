-- Groups are the highlight group definitions. The keys of this table are the name of the highlight
-- groups that will be overridden. The value is a table with the following values:
--   - fg, bg, style, sp, link,
--
-- Just like `spec` groups support templates. This time the template is based on a spec object.
local groups = {
  -- As with specs and palettes, the values defined under `all` will be applied to every style.
  nightfox = {
    -- As with specs and palettes, a specific style's value will be used over the `all`'s value.
    WinSeparator = { fg = "#81b29a"},
  },
}
require("nightfox").setup({
  groups = groups
})

vim.cmd.colorscheme "nightfox"
