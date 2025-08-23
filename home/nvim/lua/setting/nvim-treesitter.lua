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

-------------------------------------
-- Markdownパーサを強制使用して取得
-------------------------------------
local function get_md_node_at_cursor(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "markdown", {})
  if not ok or not parser then return nil end
  local pos = vim.api.nvim_win_get_cursor(0)
  local row, col = pos[1] - 1, pos[2]
  local tree = parser:parse()[1]
  if not tree then return nil end
  local root = tree:root()
  return root and root:named_descendant_for_range(row, col, row, col) or nil
end


local function find_child(node, wanted_types)
  if not node then return nil end
  for child in node:iter_children() do
    if wanted_types[child:type()] then
      return child
    end
  end
  return nil
end

local function find_fence_content_via_markdown(bufnr)
  local n = get_md_node_at_cursor(bufnr)
  while n do
    if n:type() == "fenced_code_block" then
      local content = find_child(n, { code_fence_content = true })
      -- info_string も返す
      local info_node = find_child(n, { info_string = true })
      local info = nil
      if info_node then
        info = vim.treesitter.get_node_text(info_node, bufnr)
      end
      return content or n, info
    end
    n = n:parent()
  end
  return nil, nil
end

-------------------------------------
-- 言語名の抽出と判定
-------------------------------------
local function parse_lang_from_info(info)
  if not info or info == "" then return nil end
  local lang = info:match("^%s*([%w_+%.%-]+)")
  if not lang or lang == "" then return nil end
  -- よくある表記ゆれを吸収
  local map = {
    viml = "vim",
    vimscript = "vim",
    vim = "vim",
    lua = "lua",
    luau = "lua",
    sh = "sh",
    shell = "sh",
    posix = "sh",
    bash = "bash",
    zsh = "zsh",
  }
  return (map[lang] or lang):lower()
end

-------------------------------------
-- フェンス中身を文字列として取得（```除外）
-------------------------------------
local function get_fence_text(bufnr, node)
  local sr, sc, er, ec = node:range() -- endはexclusive

  -- exclusive→inclusive調整
  if ec == 0 then
    er = er - 1
    if er < sr then return {} end
    local last = vim.api.nvim_buf_get_lines(bufnr, er, er + 1, true)[1] or ""
    ec = #last
  else
    ec = ec - 1
  end
  -- 「終端行が閉じフェンス」なら1行手前に寄せる
  local last_line = vim.api.nvim_buf_get_lines(bufnr, er, er + 1, true)[1] or ""
  if last_line:match("^%s*`%s*`%s*`") then
    er = er - 1
    if er < sr then return {} end
    local prev = vim.api.nvim_buf_get_lines(bufnr, er, er + 1, true)[1] or ""
    ec = #prev
  end
  return vim.api.nvim_buf_get_text(bufnr, sr, sc, er, ec, {})
end

-------------------------------------
-- 実行器: Vim / Lua / Sh
-------------------------------------
local function exec_vim(lines)
  local tmp = vim.fn.tempname() .. ".vim"
  vim.fn.writefile(lines, tmp)
  vim.cmd.source(tmp)
  vim.notify("Sourced (Vim): " .. tmp, vim.log.levels.INFO)
end


local function exec_lua(lines)
  local tmp = vim.fn.tempname() .. ".lua"
  vim.fn.writefile(lines, tmp)
  vim.cmd.luafile(tmp)
  vim.notify("Sourced (Lua): " .. tmp, vim.log.levels.INFO)
end

local function exec_shell(lines, shell_name) -- shell_name: "sh"|"bash"|"zsh"
  local ext = (shell_name == "zsh" and ".zsh") or (shell_name == "bash" and ".bash") or ".sh"
  local tmp = vim.fn.tempname() .. ext
  vim.fn.writefile(lines, tmp)
  local out = vim.fn.system({ shell_name, tmp })
  local code = vim.v.shell_error
  if code == 0 then
    vim.notify("Shell OK (" .. shell_name .. "):\n" .. out, vim.log.levels.INFO, { title = "Fence Exec" })
  else
    vim.notify("Shell NG (" .. shell_name .. ") exit=" .. code .. ":\n" .. out, vim.log.levels.ERROR,
      { title = "Fence Exec" })
  end
end

-------------------------------------
-- メイン: 言語自動判定で実行
-------------------------------------
local function exec_fence_auto()
  local bufnr = vim.api.nvim_get_current_buf()

  local content_node, info = find_fence_content_via_markdown(bufnr)
  if not content_node then
    vim.notify("Not inside a fenced code block", vim.log.levels.WARN)
    return
  end
  local lines = get_fence_text(bufnr, content_node)
  if #lines == 0 then
    vim.notify("Empty fence content", vim.log.levels.WARN)
    return
  end


  local lang = parse_lang_from_info(info)
  -- 既定: info_string が無い/不明 → Vim とみなす（必要なら "markdown" にも対応可）
  if not lang then lang = "vim" end

  if lang == "vim" then
    exec_vim(lines)
  elseif lang == "lua" then
    exec_lua(lines)
  elseif lang == "bash" or lang == "zsh" or lang == "sh" then
    exec_shell(lines, lang)
  else
    -- 未対応言語: とりあえず Vim として実行するか、エラーにする
    vim.notify(("Unsupported fence language: %s"):format(lang), vim.log.levels.ERROR)
  end
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(args)
    vim.api.nvim_buf_create_user_command(args.buf, "FenceExec", exec_fence_auto, {})
    vim.keymap.set("n", "<leader>qr", exec_fence_auto,
      { buffer = args.buf, desc = "Run fenced code content (force markdown parser)" })
  end,
})
