# fzf-hoogle.vim (works only on Linux and macOS)

(neo)vim plugin that uses fzf for previewing hoogle search results
![fzf-hoogle.vim in action](https://github.com/monkoose/fzf-hoogle-images/blob/master/fzf-hoogle-action.gif?raw=true)

## Requirements

 - vim 8.1 or neovim 0.4
 - [fzf](https://github.com/junegunn/fzf)
 - [hoogle](https://github.com/ndmitchell/hoogle)
 - [jq](https://github.com/stedolan/jq) - for processing json
 - [curl](https://github.com/curl/curl) - for retrieving source code
 - sed, awk, tee - should be in any Linux distro

 Since v1.2 requires hoogle 5.0.17.13 and above to properly restrict number of the items from hoogle search results.

**Tested only on Linux**.

## Installation

Using [vim-plug](https://github.com/junegunn/vim-plug)
```
Plug 'junegunn/fzf', {'dir': '~/.fzf', 'do': './install --all'}

Plug 'monkoose/fzf-hoogle.vim'
```
Or use any other plugin manager. I bet you know it better than I'm.

## Usage

`:Hoogle` or append it with initial search like `:Hoogle >>=`.

To open fzf window in a new fullscreen tab just append command with exclamation mark `:Hoogle!`

If you don't know how to properly search with hoogle, then look at the [hoogle documentation](https://github.com/ndmitchell/hoogle#searches).

**Inside fzf window**

`enter` to research hoogle database with the current query.

`alt-s` for previewing source code. Retrieving source code is a synchronous process inside
vim/neovim. So open the preview window with a source that wasn't previously cached can take some time,
please just be patient, the editor will hang for this time.
Package and module items do not have a link to source code, so `alt-s` should open the default browser
and link to package/module documentation. If it doesn't work (perhaps if you are on macOS), then
change `g:hoogle_open_link` option to open links with the CLI tool.

`Esc` or `ctrl-c` to close fzf window.


Inside the preview window with source code you can hit `q` to close it.

You can open `:Hoogle` appended with a word under the cursor with this command. Use a key combination that
suitable for you. In my config it is `<space>hh`:
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

| Variable                   | Description                                                                     | Default                                            |
|----------------------------|---------------------------------------------------------------------------------|----------------------------------------------------|
| `g:loaded_hoogle`          | Any value deactivates the plugin.                                               |                                                    |
| `g:hoogle_path`            | Path to hoogle executable.                                                      | `'hoogle'`                                         |
| `g:hoogle_preview_height`  | Change height of the source code preview window.                                | `22`                                               |
| `g:hoogle_fzf_window`      | Change fzf window.<sup>1</sup>                                                  | neovim - `{"window": "call hoogle#floatwindow(32, 132)"}`. vim - `{'down': '50%'}` |
| `g:hoogle_fzf_header`      | Change fzf window header.                                                       | 'enter - research with query  alt-s - source code' |
| `g:hoogle_fzf_preview`     | Change fzf preview split.                                                       | `'right:60%:wrap'`                                 |
| `g:hoogle_count`           | Restrict fzf count lines by this number.                                        | `500`                                              |
| `g:hoogle_open_link`       | CLI tool to open a link in the default browser. On macOs change it to `'open'`  | `'xdg-open'` if it is executable, else `''`        |
| `g:hoogle_allow_cache`     | Activates/deactivates caching.                                                  | `1`                                                |
| `g:hoogle_cache_dir`       | Location of the cache directory, it should end with a slash.                    | `'~/.cache/fzf-hoogle/'`                           |
| `g:hoogle_cacheable_size`  | Cache only pages whose size exceeds this option. Size in kilobytes.<sup>2</sup> | `500`                                              |
| `g:hoogle_enable_messages` | Activates/deactivates echoing of the fzf-hoogle messages.                       | `1`                                                |

**1** - for neovim you can change floating window size by changing parameters of `hoogle#floatwindow(rows, columns)`

**2** - cache only documentation pages, soruce pages rarely exceed 500K


## License
MIT
