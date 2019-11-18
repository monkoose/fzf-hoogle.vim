if exists('g:loaded_hoogle')
  finish
endif
let g:loaded_hoogle = 1

if !executable('jq')
    echoerr '`jq` is not installed.'
    finish
endif

command! -nargs=* -bang Hoogle call hoogle#run(<q-args>, <bang>0)
