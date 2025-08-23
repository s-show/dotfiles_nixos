if vim.fn.exists(':restart') >= 1 then
  local M = {}

  -- 保存先（Neovimの state ディレクトリ配下）
  local base = vim.fn.stdpath("state") .. "/autorestore"
  local session = base .. "/last_session.vim"
  local flag = base .. "/restore.flag"

  local function ensure_dir()
    if vim.fn.isdirectory(base) == 0 then
      vim.fn.mkdir(base, "p")
    end
  end

  local function file_exists(path)
    return vim.uv.fs_stat(path) ~= nil
  end

  local function rm(path)
    -- 存在しない場合のエラーは無視したいので pcall
    pcall(vim.uv.fs_unlink, path)
  end
  -- --------------------------------------

  -- 1) 再起動前に状態を保存してフラグを立てる
  function M.save_for_restart()
    ensure_dir()
    -- セッションに必要なオプション（端末バッファも復元したい場合は 'terminal' を入れる）
    vim.opt.sessionoptions:append("terminal")
    vim.opt.sessionoptions:append("buffers")
    vim.opt.sessionoptions:append("resize")
    vim.opt.sessionoptions:append("tabpages")

    -- セッション + shada 保存
    vim.cmd("silent! mksession! " .. vim.fn.fnameescape(session))
    vim.cmd("silent! wshada!")

    -- フラグ作成（軽いメタ情報）
    local cwd = (vim.uv.cwd and vim.uv.cwd()) or vim.fn.getcwd() or ""
    vim.fn.writefile({
      ("cwd=%s"):format(cwd),
      ("time=%s"):format(os.date("!%Y-%m-%dT%H:%M:%SZ")),
      ("nvim=%s"):format(vim.v.progpath or vim.v.progname or "nvim"),
    }, flag)

    if vim.fn.exists(":restart") == 2 then
      vim.notify("State saved. Restarting Neovim…", vim.log.levels.INFO)
      vim.cmd('silent! wall')
      vim.cmd("silent! restart")
    else
      vim.notify("State saved. Quit and start Neovim again to auto-restore.", vim.log.levels.INFO)
    end
  end

  -- 2) 起動時に自動で復元
  function M.maybe_restore_on_start()
    if not (file_exists(flag) and file_exists(session)) then
      return
    end

    -- LSP 警告回避のため、関数ラップで渡す
    pcall(function() vim.cmd("silent! rshada!") end)
    pcall(function() vim.cmd("silent! source " .. vim.fn.fnameescape(session)) end)

    -- 片付け
    rm(flag)
    rm(session)

    vim.schedule(function()
      vim.notify("Restored previous session.", vim.log.levels.INFO)
    end)
  end

  vim.api.nvim_create_user_command("RestartWithRestore", function()
    M.save_for_restart()
  end, { desc = "Save session+shada and restart (or prompt manual restart)" })

  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      vim.schedule(M.maybe_restore_on_start)
    end,
  })

  return M
end
