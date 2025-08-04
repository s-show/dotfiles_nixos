--=======================================================================================
--見た目系
--=======================================================================================
-- 行番号を表示
vim.opt.number = true
-- 現在の行を強調表示
vim.opt.cursorline = true
-- カーソルを行末より先に移動できないようにする
vim.opt.virtualedit = 'none'
-- インデントはスマートインデント
vim.opt.smartindent = true
-- ビープ音を可視化
vim.opt.visualbell = true
-- 括弧入力時の対応する括弧を表示
vim.opt.showmatch = true
-- コマンドラインの補完
vim.opt.wildmode = 'longest,list'
-- シンタックスハイライトの有効化
vim.opt.syntax = 'on'
-- 折り返された行の先頭に表示する文字列
vim.opt.showbreak = '↪'
-- vim.opt.showbreak = '+++'
-- TUI で24ビットカラーを使えるようにする
-- この設定を忘れると各種テーマの色が正確に再現されない
vim.opt.termguicolors = true
vim.opt.laststatus = 3
-- 折り返しの調整
vim.opt.breakindent = true
vim.opt.formatoptions = 'l'
vim.opt.lbr = true

--=======================================================================================
-- Tab系
--=======================================================================================
-- Tab文字を半角スペースにする
vim.opt.expandtab = true
-- 行頭以外のTab文字の表示幅（スペースいくつ分）
vim.opt.tabstop = 2
-- 行頭でのTab文字の表示幅
vim.opt.shiftwidth = 2

-- vim.opt.winblend = 0 -- ウィンドウの不透明度
-- vim.opt.pumblend = 0 -- ポップアップメニューの不透明度
vim.opt.pumheight = 15 -- 補完候補の表示数の上限

--=======================================================================================
-- cmdline 系
--=======================================================================================
local ok, extui = pcall(require, 'vim._extui')
if ok then
  extui.enable({
    enable = true,    -- extuiを有効化
    msg = {
      target = 'cmd', -- 'cmd'か'msg'だがcmdheight=0だとどっちでも良い？（記事後述）
      timeout = 5000, -- boxメッセージの表示時間 ミリ秒
    },
  })

  vim.opt.cmdheight = 0

  local extui_colorscheme = "dayfox"

  -- extuiのカラースキームを自動設定
  local augroup = vim.api.nvim_create_augroup("atusy-extui-cmdline", {})
  vim.api.nvim_create_autocmd("CmdlineEnter", {
    group = augroup,
    callback = function()
      if not require("vim._extui.shared").cfg.enable then
        return
      end
      local tabpage = vim.api.nvim_get_current_tabpage()
      local extuiwins = require("vim._extui.shared").wins
      for _, w in pairs(extuiwins) do
        require("styler").set_theme(w, { colorscheme = extui_colorscheme })
      end
    end,
  })

  local function hide_msgbox()
    -- 表示中のウィンドウ一覧を取得
    local wins = vim.api.nvim_tabpage_list_wins(vim.api.nvim_get_current_tabpage())

    -- ウィンドウごとに表示中のバッファのファイルタイプを確認
    -- msgboxを見つけたらhideして、関数を終了
    for _, win in ipairs(wins) do
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = vim.bo[buf].filetype
      if ft == "msgbox" then
        vim.api.nvim_win_set_config(win, { hide = true })
        return
      end
    end
  end

  vim.keymap.set("n", "<C-L>", function()
    hide_msgbox()
    return "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>"
  end, { expr = true })
end

function Win_list()
  -- 表示中のウィンドウ一覧を取得
  local tabs = vim.api.nvim_list_tabpages()
  for _, tab in ipairs(tabs) do
    local wins = vim.api.nvim_tabpage_list_wins(tab)
    for _, win in ipairs(wins) do
      local buf = vim.api.nvim_win_get_buf(win)
      local buftype = vim.api.nvim_get_option_value('buftype', { buf = buf })
      local ft = vim.bo[buf].filetype
      local name = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
      vim.notify('bufnum: ' .. buf .. ', buftype: ' .. buftype .. ', filetype: ' .. ft .. ', name: ' .. name)
    end
  end
end
