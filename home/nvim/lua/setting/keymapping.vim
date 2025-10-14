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

" 空行での編集開始時に自動でインデント
nnoremap <expr> i empty(getline('.')) ? '"_cc' : 'i'
nnoremap <expr> A empty(getline('.')) ? '"_cc' : 'A'
