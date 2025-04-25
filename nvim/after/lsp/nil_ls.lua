-- Nix 言語の LSP 設定
-- LSP は `nil_ls`, Formatter は `nixfmt`.
return {
  settings = {
    ['nil'] = {
      formatting = {
        command = { "nixfmt" }
      }
    }
  }
}
