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
vim.opt.laststatus = 1
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

vim.opt.winblend = 0 -- ウィンドウの不透明度
vim.opt.pumblend = 0 -- ポップアップメニューの不透明度
vim.opt.pumheight = 15 -- 補完候補の表示数の上限
