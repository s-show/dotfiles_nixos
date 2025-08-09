" サブモードを利用して gjjj... で折り返し行を移動するキーマッピング
" [Vim で折り返し行を簡単に移動できるサブモード・テクニック](https://zenn.dev/mattn/articles/83c2d4c7645faa)
nmap gj gj<SID>g
nmap gk gk<SID>g
nnoremap <script> <SID>gj gj<SID>g
nnoremap <script> <SID>gk gk<SID>g
nmap <SID>g <Nop>

" Markdownファイルでは j を gj, k を gk にマッピングする
augroup MarkdownScrollFix
  autocmd!
  " FileType markdownイベント時に以下のマッピングを設定
  " <buffer>を追加することで、キーマッピングが現在のバッファのみに適用されます。
  autocmd FileType markdown nnoremap <buffer> j gj
  autocmd FileType markdown nnoremap <buffer> k gk
  autocmd FileType markdown nnoremap <buffer> gj j
  autocmd FileType markdown nnoremap <buffer> gk k
augroup END

" サブモードを利用して <CTRL-w>++++... でウィンドウをリサイズするキーマッピング
" [Vim で折り返し行を簡単に移動できるサブモード・テクニック](https://zenn.dev/mattn/articles/83c2d4c7645faa)
nmap <C-w>+ <C-w>+<SID>ws
nmap <C-w>- <C-w>-<SID>ws
nmap <C-w>> <C-w>><SID>ws
nmap <C-w>< <C-w><<SID>ws
nnoremap <script> <SID>ws+ <C-w>+<SID>ws
nnoremap <script> <SID>ws- <C-w>-<SID>ws
nnoremap <script> <SID>ws> <C-w>><SID>ws
nnoremap <script> <SID>ws< <C-w><<SID>ws
nmap <SID>ws <Nop>

" [Vimでz連打でカーソル行を画面中央・上・下に移動させる](https://zenn.dev/vim_jp/articles/67ec77641af3f2)
" nmap zz zz<sid>(z1)
" nnoremap <script> <sid>(z1)z zt<sid>(z2)
" nnoremap <script> <sid>(z2)z zb<sid>(z3)
" nnoremap <script> <sid>(z3)z zz<sid>(z1)

" imap j j<SID>g
" inoremap <script> <SID>gj <Esc>u
" imap <SID>g <Nop>
