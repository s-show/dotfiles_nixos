"=======================================================================================
" IME制御の設定
"=======================================================================================
command! ImeOff silent !spzenhan.exe 0
command! ImeOn  silent !spzenhan.exe 1

function! ImeAutoOff()
  let b:ime_status=system('spzenhan.exe')
  :silent ImeOff
endfunction

function! ImeAutoOn()
  if !exists('b:ime_status')
    let b:ime_status=0
  endif
  if b:ime_status==1
    :silent ImeOn
  endif
endfunction

" IME off when in insert mode
augroup InsertHook
  autocmd!
  autocmd InsertLeave * call ImeAutoOff()
  autocmd InsertEnter * call ImeAutoOn()
augroup END
