# fzf-hoogle.vim

neovim and vim plugin for previewing hoogle results with fzf
![fzf-hoogle.vim in action](https://github.com/monkoose/fzf-hoogle-images/blob/master/fzf-hoogle-action.gif?raw=true)

## Requirements

 - vim 8.1 or neovim 0.4
 - [fzf](https://github.com/stedolan/jq)
 - [hoogle](https://github.com/ndmitchell/hoogle)
 - [jq](https://github.com/stedolan/jq) - for processing json
 - curl - for retrieving source code
 - sed, awk, tee, head - should be in any linux distro
 
**Tested only on linux**.

## Installation

Using [vim-plug](https://github.com/junegunn/vim-plug)
```
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

Plug 'monkoose/fzf-hoogle.vim'
```
Or use any other plugin manager. I bet you know it better then I'm.

## Usage

Just run `:Hoogle` command or append it with initial search like `:Hoogle >>=`.

Inside fzf window use `enter` to research hoogle database with current query.

For previewing source code use `alt-s`. Retrieving source code is synchronous process inside vim/neovim and so open preview window with it can take some time, please just be patient. Maybe I will improve this behavior later.

Inside preview window with source code you can hit `q` to close it.

You can open `:Hoogle` appended with word under the cursor with this command. Use key combination that suitable for you. In my config it is `\<space\>hh:
```
augroup HoogleMaps
  autocmd!
  autocmd FileType haskell nnoremap <buffer> <space>hh :Hoogle <c-r>=expand("<cword>")<CR><CR>
augroup END
```
Or you can set it as `keywordprg` and open fzf-hoogle window with `K`:
```
augroup HoogleMaps
  autocmd!
  autocmd FileType haskell setlocal keywordprg=:Hoogle
augroup END
```

## Options

 - `g:loaded_hoogle` - any value deactivates plugin.
 - `g:hoogle_path` - path to hoogle executable. String. Default: "hoogle"
 - `g:hoogle_preview_height` - change height of source code preview window. Int. Default: 22
 - `g:hoogle_fzf_window` - change fzf window. One key dictionary. Default: float window in neovim and `{'down': '50%'}` in vim
 - `g:hoogle_fzf_header` - change fzf window header. String. Default: help info
 - `g:hoogle_fzf_preview` - change fzf preview split. String. Default: "right:60%:wrap"
 - `g:hoogle_tmp_file` - change location of temporary file. String. Default: `/tmp/hoogle-query.json`
 - `g:hoogle_count` - restrict fzf count lines by this number. Int. Default: 1000

## TODO

 - Make it less error prone
 - Add vim documentation

## License
MIT
