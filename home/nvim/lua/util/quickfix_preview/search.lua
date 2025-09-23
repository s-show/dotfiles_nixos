--- ファイル検索機能モジュール.
-- @module quickfix_preview.search

local util = require('util.utility')

local M = {}

local default_exclude_dirs = {
  ".git", ".svn", ".hg", ".bzr",
  "node_modules", "vendor",
  ".venv", "venv", "env",
  "__pycache__", ".pytest_cache", ".mypy_cache", ".tox",
  "dist", "build", "target",
  ".idea", ".vscode",
  ".DS_Store", ".cache",
  ".npm", ".yarn",
  "coverage", ".nyc_output",
  ".next", ".nuxt", "out"
}

--- fdが利用可能かチェック.
local function is_fd_available()
  return vim.fn.executable("fd") == 1
end

--- findコマンドを構築.
-- @param exclude_dirs string[] 検索対象から除外するディレクトリのリスト
-- @param search_file string 検索したいファイル名
-- @return string find 検索のコマンド文字列
local function build_find_command(exclude_dirs, search_file)
  local prune_parts = {}
  for i, dir in ipairs(exclude_dirs) do
    table.insert(prune_parts, "-name " .. vim.fn.shellescape(dir))
    if i < #exclude_dirs then
      table.insert(prune_parts, "-o")
    end
  end

  if util.is_blank_text(search_file) == false then
    local pattern = "*" .. search_file .. "*"
    return string.format(
      [[find . -type d \( %s \) -prune -o -name %s -type f -print | awk '{ flag = ($0 ~ /(^|\/)\./ ? 0 : 1); print flag "|" $0 }' | sort -t'|' -k1,1 -k2,2 | cut -d'|' -f2-]],
      table.concat(prune_parts, " "),
      vim.fn.shellescape(pattern)
    )
  else
    return string.format(
      [[find . -type d \( %s \) -prune -o -type f -print | awk '{ flag = ($0 ~ /(^|\/)\./ ? 0 : 1); print flag "|" $0 }' | sort -t'|' -k1,1 -k2,2 | cut -d'|' -f2-]],
      table.concat(prune_parts, " ")
    )
  end
end

--- fdコマンドを構築.
-- @param exclude_dirs string[] 検索対象から除外するディレクトリのリスト
-- @param search_file string 検索したいファイル名
-- @return string fd 検索のコマンド文字列
local function build_fd_command(exclude_dirs, search_file)
  local exclude_parts = {}
  for _, dir in ipairs(exclude_dirs) do
    table.insert(exclude_parts, "--exclude " .. vim.fn.shellescape(dir))
  end
  local fd_cmd = ""
  if util.is_blank_text(search_file) == false then
    fd_cmd = string.format(
      [[fd %s --type f --hidden %s . | awk '{ flag = ($0 ~ /(^|\/)\./ ? 0 : 1); print flag "|" $0 }' | sort -t'|' -k1,1 -k2,2 | cut -d'|' -f2-]],
      vim.fn.shellescape(search_file),
      table.concat(exclude_parts, " ")
    )
  else
    fd_cmd = string.format(
      [[fd --type f --hidden %s . | awk '{ flag = ($0 ~ /(^|\/)\./ ? 0 : 1); print flag "|" $0 }' | sort -t'|' -k1,1 -k2,2 | cut -d'|' -f2-]],
      table.concat(exclude_parts, " ")
    )
  end

  return fd_cmd
end

--- ファイル検索関数.
-- @param search_file string 検索したいファイル名
-- @param opts table オプション (debug_mode, exclude_dirs)
-- @return string[]|nil ファイルリストまたはnil
function M.get_files(search_file, opts)
  opts = opts or {}
  local debug_mode = opts.debug_mode or false
  local exclude_dirs = opts.exclude_dirs or default_exclude_dirs
  local use_fd = is_fd_available()

  local cmd
  if use_fd then
    cmd = build_fd_command(exclude_dirs, search_file)
  else
    cmd = build_find_command(exclude_dirs, search_file)
  end

  if debug_mode then
    print(cmd)
  end

  local file_list = vim.fn.systemlist(cmd)
  if vim.v.shell_error ~= 0 then
    local error_msg = use_fd and "fd" or "find"
    vim.notify(error_msg .. " エラー: " .. (file_list[1] or "不明なエラー"), vim.log.levels.ERROR)
    return nil
  end
  return file_list
end

return M

