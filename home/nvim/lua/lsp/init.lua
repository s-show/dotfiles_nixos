vim.lsp.config('*', {
    -- capabilities = require('ddc_source_lsp').make_client_capabilities(),
    -- capabilities = require('cmp_nvim_lsp').default_capabilities()
  }
)
-- vim.lsp.util.make_position_params(0, 'utf-8')

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
    local bufopt = { noremap = true, silent = true }
    -- LSP によって `K` が自動的にマッピングされたりされなかったりするので、
    -- やむを得ず `vim.fn.maparg()` を使ってマッピングの有無を確認している。
    if vim.fn.maparg('K', 'n') ~= '' then
      vim.api.nvim_buf_del_keymap(bufnr, 'n', 'K')
    end
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', bufopt)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gh', '<cmd>lua vim.lsp.buf.hover()<CR>', bufopt)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', bufopt)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<CR>', bufopt)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gn', '<cmd>lua vim.lsp.buf.rename()<CR>', bufopt)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>', bufopt)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', bufopt)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gx', '<cmd>lua vim.diagnostic.open_float()<CR>', bufopt)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'g[', '<cmd>lua vim.diagnostic.goto_prev()<CR>', bufopt)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'g]', '<cmd>lua vim.diagnostic.goto_next()<CR>', bufopt)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gf', '<cmd>lua vim.lsp.buf.format({buffer = true})<CR>', bufopt)
  end
})

local lsp_names = {
  'clangd',
  'lua_ls',
  'html',
  'ts_ls',
  'eslint',
  'emmet_ls',
  'nixd',
}

vim.lsp.enable(lsp_names)

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
