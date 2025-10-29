-- テストで古いバージョンの Neovim を起動したときのエラー回避
if vim.fn.has('nvim-0.11') == 1 then
  vim.lsp.config('*', {
    capabilities = require('ddc_source_lsp').make_client_capabilities(),
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
  -- local capabilities = require("blink.cmp").get_lsp_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
end

vim.diagnostic.config({
  virtual_text = { prefix = "●", spacing = 4 },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = true,
    header = "",
    prefix = "",
  },
})

-- 定義を floating window で表示する関数
local function peek_definition()
  -- バッファに接続されている LSP クライアントを取得
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    vim.notify("LSP クライアントが見つかりません", vim.log.levels.WARN)
    return
  end

  local offset_encoding = clients[1].offset_encoding or 'utf-16'
  local params = vim.lsp.util.make_position_params(0, offset_encoding)
  local result = vim.lsp.buf_request_sync(0, 'textDocument/definition', params, 1000)

  if not result or vim.tbl_isempty(result) then
    vim.notify("定義が見つかりません", vim.log.levels.WARN)
    return
  end

  -- 最初の LSP サーバーの結果を取得
  for _, res in pairs(result) do
    if res.result then
      local location = vim.islist(res.result) and res.result[1] or res.result
      vim.lsp.util.preview_location(location, { border = 'rounded', max_width = 80, max_height = 20 })
      return
    end
  end
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
    vim.keymap.set('n', '<C-g>d', '<cmd>lua vim.lsp.buf.definition()<CR>',
      vim.tbl_extend('force', bufopt, { desc = 'Go to definition' }))
    vim.keymap.set('n', '<C-g>p', peek_definition,
      vim.tbl_extend('force', bufopt, { desc = 'Peek definition' }))
    vim.keymap.set('n', '<C-g>h', '<cmd>lua vim.lsp.buf.hover({border = "rounded"})<CR>',
      vim.tbl_extend('force', bufopt, { desc = 'Show hover information' }))
    vim.keymap.set('n', '<C-g>i', '<cmd>lua vim.lsp.buf.implementation()<CR>',
      vim.tbl_extend('force', bufopt, { desc = 'Go to implementation' }))
    vim.keymap.set('n', '<C-g>s', '<cmd>lua vim.lsp.buf.signature_help({border = "rounded"})<CR>',
      vim.tbl_extend('force', bufopt, { desc = 'Show signature help' }))
    vim.keymap.set('n', '<C-g>n', '<cmd>lua vim.lsp.buf.rename()<CR>',
      vim.tbl_extend('force', bufopt, { desc = 'Rename symbol' }))
    vim.keymap.set('n', '<C-g>a', '<cmd>lua vim.lsp.buf.code_action()<CR>',
      vim.tbl_extend('force', bufopt, { desc = 'Code action' }))
    vim.keymap.set('n', '<C-g>r', '<cmd>lua vim.lsp.buf.references()<CR>',
      vim.tbl_extend('force', bufopt, { desc = 'Show references' }))
    vim.keymap.set('n', '<C-g>x', '<cmd>lua vim.diagnostic.open_float()<CR>',
      vim.tbl_extend('force', bufopt, { desc = 'Show diagnostic' }))
    vim.keymap.set('n', '<C-g>[', '<cmd>lua vim.diagnostic.jump({ count = -1 })<CR>',
      vim.tbl_extend('force', bufopt, { desc = 'Previous diagnostic' }))
    vim.keymap.set('n', '<C-g>]', '<cmd>lua vim.diagnostic.jump({ count = 1 })<CR>',
      vim.tbl_extend('force', bufopt, { desc = 'Next diagnostic' }))
    vim.keymap.set('n', '<C-g>f', '<cmd>lua vim.lsp.buf.format({buffer = true})<CR>',
      vim.tbl_extend('force', bufopt, { desc = 'Format buffer' }))

    -- Typescript の型情報を Inlay Hints で表示するための設定
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
    end
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
