if exists('g:loaded_hoogle')
  finish
endif
let g:loaded_hoogle = 1

if !executable('hoogle')
    echom 'fzf-hoogle: `hoogle` is not installed. Plugin disabled.'
    finish
endif

call system('hoogle')
if v:shell_error != 0 
    echom 'fzf-hoogle: `empty hoogle invocation failed - could be that database is not generated`'
    finish
endif


if !executable('jq')
    echom 'fzf-hoogle: `jq` is not installed. Plugin disabled.'
    finish
endif

command! -nargs=* -bang Hoogle call hoogle#run(<q-args>, <bang>0)
