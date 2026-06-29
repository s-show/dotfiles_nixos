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
