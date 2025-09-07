-- テストで古いバージョンの Neovim を起動したときのエラー回避
if vim.fn.has('nvim-0.11') == 1 then
  vim.lsp.config('*', {
    capabilities = require('ddc_source_lsp').make_client_capabilities(),
    -- capabilities = require('cmp_nvim_lsp').default_capabilities(),
    -- capabilities = require('blink.cmp').get_lsp_capabilities(),
  })

  local lsp_names = {
    'clangd',
    'lua_ls',
    'html',
    'css',
    'ts_ls',
    'eslint',
    'emmet_ls',
    'nixd',
    'ruby_lsp',
    'bash-language-server',
  }

  vim.lsp.enable(lsp_names)
  local _, result = pcall(vim.lsp.document_color.enable, true, 0, { style = 'virtual' })
else
  local capabilities = require("ddc_source_lsp").make_client_capabilities()
  -- local capabilities = require("cmp_nvim_lsp").default_capabilities()
  -- local capabilities = require("blink.cmp").get_lsp_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
end

-- You will likely want to reduce updatetime which affects CursorHold
-- note: this setting is global and should be set only once
vim.api.nvim_create_autocmd(
  { "CursorHold", "CursorHoldI" },
  {
    group = vim.api.nvim_create_augroup(
      "float_diagnostic",
      { clear = true }
    ),
    callback = function()
      vim.diagnostic.open_float(nil, { focus = false })
    end
  })

-- 2. key mapping
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    local bufopt = { buffer = bufnr, noremap = true, silent = true }
    -- LSP によって `K` が自動的にマッピングされたりされなかったりするので、
    -- やむを得ず `vim.fn.maparg()` を使ってマッピングの有無を確認している。
    if vim.fn.maparg('K', 'n') ~= '' then
      vim.api.nvim_buf_del_keymap(bufnr, 'n', 'K')
    end
    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', bufopt)
    vim.keymap.set('n', 'gh', '<cmd>lua vim.lsp.buf.hover()<CR>', bufopt)
    vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', bufopt)
    vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<CR>', bufopt)
    vim.keymap.set('n', 'gn', '<cmd>lua vim.lsp.buf.rename()<CR>', bufopt)
    vim.keymap.set('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>', bufopt)
    vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', bufopt)
    vim.keymap.set('n', 'gx', '<cmd>lua vim.diagnostic.open_float()<CR>', bufopt)
    vim.keymap.set('n', 'g[', '<cmd>lua vim.diagnostic.jump({ count = -1 })<CR>', bufopt)
    vim.keymap.set('n', 'g]', '<cmd>lua vim.diagnostic.jump({ count = 1 })<CR>', bufopt)
    vim.keymap.set('n', 'gf', '<cmd>lua vim.lsp.buf.format({buffer = true})<CR>', bufopt)
  end
})

local kind_icons = {
  Text = "",
  Method = "󰆧",
  Function = "󰊕",
  Constructor = "",
  Field = "󰇽",
  Variable = "󰂡",
  Class = "󰠱",
  Interface = "",
  Module = "",
  Property = "󰜢",
  Unit = "",
  Value = "󰎠",
  Enum = "",
  Keyword = "󰌋",
  Snippet = "",
  Color = "󰏘",
  File = "󰈙",
  Reference = "",
  Folder = "󰉋",
  EnumMember = "",
  Constant = "󰏿",
  Struct = "",
  Event = "",
  Operator = "󰆕",
  TypeParameter = "󰅲",
}
