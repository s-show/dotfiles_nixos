-- ビルトインTreesitter機能を完全に無効化
vim.treesitter.start = function() end
vim.treesitter.stop = function() end

-- nvim-treesitterの通常設定
require('nvim-treesitter.configs').setup {
  parser_install_dir = vim.fn.stdpath("data") .. "/treesitter",
  ensure_installed = {},
  auto_install = false,
  sync_install = false,
  highlight = {
    enable = true,
  },
}

-- パーサーディレクトリを追加
vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/treesitter")

--- Markdown ファイルの現在のカーソル位置にあるTree-sitterノードを取得する
--- @param bufnr number|nil バッファ番号（省略時は現在のバッファ）
--- @return TSNode|nil カーソル位置のノード、パーサーが取得できない場合はnil
local function get_md_node_at_cursor(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "markdown", {})
  if not ok or not parser then return nil end

  -- カーソル位置
  local pos = vim.api.nvim_win_get_cursor(0)
  local row, col = pos[1] - 1, pos[2]

  -- markdown のルートからカーソル位置の最小ノードを取得
  local tree = parser:parse()[1]
  if not tree then return nil end
  local root = tree:root()
  return root and root:named_descendant_for_range(row, col, row, col) or nil
end

--- 指定したタイプの子ノードを検索する
--- @param node TSNode|nil 検索対象のノード
--- @param wanted_types table<string, boolean> 検索するノードタイプのテーブル
--- @return TSNode|nil 見つかった子ノード、見つからない場合はnil
local function find_child(node, wanted_types)
  if not node then return nil end
  for child in node:iter_children() do
    if wanted_types[child:type()] then
      return child
    end
  end
  return nil
end

--- Markdownパーサーを使用してフェンス内コンテンツのノードを検索する
--- @param bufnr number|nil バッファ番号（省略時は現在のバッファ）
--- @return TSNode|nil フェンス内コンテンツのノード、見つからない場合はnil
local function find_fence_content_via_markdown(bufnr)
  local n = get_md_node_at_cursor(bufnr)
  while n do
    if n:type() == "fenced_code_block" then
      -- 中身を表すノードを取得（通常は code_fence_content）
      local content = find_child(n, { code_fence_content = true })
      return content or n
    end
    n = n:parent()
  end
  return nil
end

--- 指定されたノードの範囲をビジュアル選択する
--- @param node TSNode 選択対象のノード
local function select_range_of_node(node)
  local bufnr = vim.api.nvim_get_current_buf()
  local sr, sc, er, ec = node:range() -- Tree-sitter: end は排他的

  -- 空範囲は何もしない
  if sr == er and sc == ec then return end

  -- 終端を 1 文字手前に詰める（exclusive -> inclusive）
  if ec == 0 then
    -- 終端が次行の先頭だった場合は、前の行の末尾に移す
    er = er - 1
    if er < sr then return end
    local last = vim.api.nvim_buf_get_lines(bufnr, er, er + 1, true)[1] or ""
    ec = #last
  else
    ec = ec - 1
  end

  -- 念のため: 終端行がフェンス（```...）なら 1 行手前の末尾に寄せる
  local last_line = vim.api.nvim_buf_get_lines(bufnr, er, er + 1, true)[1] or ""
  if last_line:match("^%s*`%s*`%s*`") then
    er = er - 1
    if er < sr then return end
    local prev = vim.api.nvim_buf_get_lines(bufnr, er, er + 1, true)[1] or ""
    ec = #prev
  end

  -- 選択実行
  vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
  vim.cmd.normal({ args = { "v" }, bang = true })
  vim.api.nvim_win_set_cursor(0, { er + 1, ec })
end

--- Markdownファイル内のコードフェンスの内容を選択する
--- カーソル位置がコードフェンス内にある場合、その内容をビジュアル選択する
local function SelectFenceContentMarkdown()
  local bufnr = vim.api.nvim_get_current_buf()
  local node = find_fence_content_via_markdown(bufnr)
  if not node then
    print("Not inside a fenced code block (checked via markdown parser)")
    return
  end
  select_range_of_node(node)
end

--- Markdownファイル内のコードフェンスの内容を実行する
--- カーソル位置がコードフェンス内にある場合、その内容を選択して:sourceコマンドで実行する
local function SourceFenceContentMarkdown()
  local bufnr = vim.api.nvim_get_current_buf()
  local node = find_fence_content_via_markdown(bufnr)
  if not node then
    print("Not inside a fenced code block (checked via markdown parser)")
    return
  end
  select_range_of_node(node)
  vim.fn.feedkeys(":source\r", 'm')
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(args)
    vim.keymap.set("n", "<leader>vc", SelectFenceContentMarkdown,
      { buffer = args.buf, desc = "Select fenced code content (force markdown parser)" })
    vim.keymap.set("n", "<leader>qr", SourceFenceContentMarkdown,
      { buffer = args.buf, desc = "Run fenced code content (force markdown parser)" })
  end,
})
