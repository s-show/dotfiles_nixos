local keycastr = require("keycastr")

keycastr.config.set {
    ignore_mouse = true,
    position = "SW",
    win_config = {
        border = "rounded",
    },
}

keycastr.enable()

vim.keymap.set('n', '<C-g>kd', function ()
  require("keycastr").disable()
end)
vim.keymap.set('n', '<C-g>ke', function ()
  require("keycastr").enable()
end)
