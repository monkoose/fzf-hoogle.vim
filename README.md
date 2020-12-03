# fzf-hoogle.vim (works only on Linux and macOS)

(neo)vim plugin that uses fzf for previewing hoogle search results
![preview image fzf-hoogle.vim](https://github.com/monkoose/fzf-hoogle-images/blob/master/fzf-hoogle.jpg?raw=true)

## Requirements

 - vim 8.1 or neovim 0.4
 - [fzf](https://github.com/junegunn/fzf)
 - [hoogle](https://github.com/ndmitchell/hoogle)
 - [jq](https://github.com/stedolan/jq) - for processing json
 - awk, tee - should be in any Linux distro

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

`enter` to start new search with the current query.

`alt-s` to open default browser with documentation. If it doesn't work (perhaps if you are on macOS), then
change `g:hoogle_open_link` option to open links with the CLI tool.

`alt-x` to copy type annotation into default register. Paste it just with `p`.

`alt-c` to copy import statement into default register.

`Esc` or `ctrl-c` to close fzf window.

You can open `:Hoogle` appended with a word under the cursor with this command. Use a key combination that
suitable for you. In my config it is `<space>hh`:
```
augroup HoogleMaps
  autocmd!
  autocmd FileType haskell nnoremap <buffer> <space>hh :Hoogle <C-r><C-w><CR>
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

| Variable                    | Description                                                                     | Default                                            |
|-----------------------------|---------------------------------------------------------------------------------|----------------------------------------------------|
| `g:loaded_hoogle`           | Any value deactivates the plugin.                                               |                                                    |
| `g:hoogle_path`             | Path to hoogle executable.                                                      | `'hoogle'`                                         |
| `g:hoogle_fzf_cache_file`   | Path to the internal fzf-hoogle cache file.                                     | `'./hoogle_cache.json'`                            |
| `g:hoogle_fzf_window`       | Change fzf window.<sup>1</sup>                                                  | neovim - `{"window": "call hoogle#floatwindow(32, 132)"}`. vim - `{'down': '50%'}` |
| `g:hoogle_fzf_header`       | Change fzf window header.                                                       | `'enter - restart with the query  alt-s - open in a browser  alt-x - copy type annotation  alt-c - copy import statement'` |
| `g:hoogle_fzf_preview`      | Change fzf preview split.                                                       | `'right:60%:wrap'`                                 |
| `g:hoogle_fzf_open_browser` | Shortcut for opening documentation in a browser.                                | `'alt-s'`                                          |
| `g:hoogle_fzf_copy_type`    | Shortcut for copying type annotation.                                           | `'alt-x'`                                          |
| `g:hoogle_fzf_copy_import`  | Shortcut for copying import statement.                                          | `'alt-c'`                                          |
| `g:hoogle_count`            | Maximum number of results by hoogle search.                                     | `500`                                              |
| `g:hoogle_open_link`        | CLI tool to open a link in the default browser. On macOS change it to `'open'`  | `'xdg-open'` if it is executable, else `''`        |
| `g:hoogle_enable_messages`  | Activates/deactivates echoing of the fzf-hoogle messages.                       | `1`                                                |

**1** - for neovim you can change floating window size by changing parameters of `hoogle#floatwindow(rows, columns)`

## License
MIT
