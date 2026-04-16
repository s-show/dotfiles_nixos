-- kakehashi の設定（init_options で言語サーバーを直接指定）
vim.lsp.config["kakehashi"] = {
  cmd = { "kakehashi" },
  filetypes = {
    "c", "cpp",
    "lua",
    "javascript", "javascriptreact", "typescript", "typescriptreact",
    "nix",
    "bash", "sh",
    "html",
    "css", "scss",
    "ruby",
  },
  init_options = {
    languageServers = {
      clangd = {
        cmd = { "clangd" },
        languages = { "c", "cpp" },
      },
      lua_ls = {
        cmd = { "lua-language-server" },
        languages = { "lua" },
      },
      eslint = {
        cmd = { "vscode-eslint-language-server", "--stdio" },
        languages = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte", "astro" },
      },
      nixd = {
        cmd = { "nixd" },
        languages = { "nix" },
      },
      bashls = {
        cmd = { "bash-language-server", "start" },
        languages = { "bash", "sh" },
      },
      html = {
        cmd = { "vscode-html-language-server", "--stdio" },
        languages = { "html" },
      },
      cssls = {
        cmd = { "vscode-css-language-server", "--stdio" },
        languages = { "css", "scss", "less" },
      },
      ts_ls = {
        cmd = { "typescript-language-server", "--stdio" },
        languages = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
      },
      emmet_ls = {
        cmd = { "emmet-ls", "--stdio" },
        languages = { "html", "css", "typescriptreact", "javascriptreact", "scss", "less" },
      },
      ruby_lsp = {
        cmd = { "ruby-lsp" },
        languages = { "ruby", "eruby" },
      },
    },
  },
}

vim.lsp.enable("kakehashi")
