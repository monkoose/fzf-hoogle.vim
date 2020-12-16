if exists('g:loaded_hoogle')
  finish
endif
let g:loaded_hoogle = 1

if !executable('jq')
    echom 'fzf-hoogle: `jq` is not installed. Plugin disabled.'
    finish
endif

let g:hoogle_path = get(g:, 'hoogle_path', 'hoogle')
if !executable(g:hoogle_path)
    echom 'fzf-hoogle: `hoogle` is not installed. Plugin disabled.'
    finish
endif

command! -nargs=* -bang Hoogle call hoogle#run(<q-args>, <bang>0)
