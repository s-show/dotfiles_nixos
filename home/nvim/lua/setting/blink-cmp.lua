local blink = require('blink.cmp')
-- autocmd で skkeleton のイベントにフックして関数を実行
function _G.blink_enable_skk()
  blink.setup({
    sources = {
      default = { 'skkeleton' }
    }
  })
end

function _G.blink_disable_skk()
  blink.setup({
    sources = {
      default = { "snippets", "lsp", "path", "buffer", "cmdline" }
    }
  })
end

vim.cmd([[
  augroup skkeleton_blink_cmp
    autocmd!
    autocmd User skkeleton-enable-pre lua _G.blink_enable_skk()
    autocmd User skkeleton-disable-pre lua _G.blink_disable_skk()
  augroup END
]])
