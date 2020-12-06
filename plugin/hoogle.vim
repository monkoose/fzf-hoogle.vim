if exists('g:loaded_hoogle')
  finish
endif
let g:loaded_hoogle = 1

if !executable('hoogle')
    echo 'fzf-hoogle: `hoogle is not installed. Plugin disabled`'
    finish
endif

if !executable('jq')
    echo 'fzf-hoogle: `jq` is not installed. Plugin disabled.'
    finish
endif

command! -nargs=* -bang Hoogle call hoogle#run(<q-args>, <bang>0)
