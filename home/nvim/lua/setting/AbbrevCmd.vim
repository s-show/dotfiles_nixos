" {{{ AbbrevCmd
" expand abbreviations immediately in command-line
let s:abbrev_cmds = {}
function! s:abbrev_cmd(raw_rhs, cmd_lhs, ...) abort
  " generate rhs of cnoremap
  const rhs = a:raw_rhs ? "'<c-u>'.." .. join(a:000, ' ') :
        \ "'<c-u>" .. substitute(join(a:000, ' '), "'", "''", 'g') .. "'"

  " pick the last character of lhs
  " example: mes -> me & s
  const lhs_except_last = slice(a:cmd_lhs, 0, -1)
  const lhs_last = slice(a:cmd_lhs, -1)

  " save rhs to handle same lhs_last character
  if !has_key(s:abbrev_cmds, lhs_last)
    let s:abbrev_cmds[lhs_last] = {}
  endif
  let s:abbrev_cmds[lhs_last][':' .. lhs_except_last] = rhs

  " make string that represents key-value pair of dict
  const rhs_list = map(items(s:abbrev_cmds[lhs_last]), {_,val -> printf("'%s':%s", val[0], val[1])})

  " execute cnoremap
  const fmt = "cnoremap <expr> %s get({%s},getcmdtype()..getcmdline(),'%s')"
  execute printf(fmt, lhs_last, join(rhs_list, ','), lhs_last)
endfunction
command! -nargs=+ -bang AbbrevCmd call s:abbrev_cmd(<bang>0, <f-args>)
" }}}

AbbrevCmd mes messages
AbbrevCmd gs GinStatus
AbbrevCmd gl GinLog
AbbrevCmd gc Gin commit
AbbrevCmd gp Gin push 
AbbrevCmd rst RestartWithRestore
