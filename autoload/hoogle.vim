" Note: for strings use '' when possible and "" if only there is
" a need to use string constants or ' inside string `:h expr-quote`
" ----------------------------------------------------------
" Options
" ----------------------------------------------------------

let s:is_nvim = has('nvim')
if s:is_nvim
  let s:window = get(g:, 'hoogle_fzf_window', {'window': 'call hoogle#floatwindow(32, 132)'})
else
  let s:window = get(g:, 'hoogle_fzf_window', {'down': '50%'})
endif

let s:hoogle_path = get(g:, 'hoogle_path', 'hoogle')
let s:count = get(g:, 'hoogle_count', 500)
let s:header = get(g:, 'hoogle_fzf_header',
      \ printf("\x1b[35m%s\x1b[m", 'enter') .. " - restart with the query\n" ..
      \ printf("\x1b[35m%s\x1b[m", 'alt-s') .. " - open in a browser\n ")
let s:fzf_preview = get(g:, 'hoogle_fzf_preview', 'right:60%:wrap')
let s:open_tool = get(g:, 'hoogle_open_link', executable('xdg-open') ? 'xdg-open' : '')
let s:enable_messages = get(g:, 'hoogle_enable_messages', 1)
let s:hoogle_fzf_dir = expand('<sfile>:h:h')
let s:preview_handler = s:hoogle_fzf_dir .. '/bin/preview.sh'
let s:cache_file = s:hoogle_fzf_dir .. '/hoogle_cache.json'

" ----------------------------------------------------------
" Hoogle
" ----------------------------------------------------------

function! hoogle#run(query, fullscreen) abort
  let prompt = strdisplaywidth(a:query) > 30 ? a:query[:27] .. '.. > ' : a:query .. ' > '
  let options = {
      \ 'sink*': function('s:Handler', [a:fullscreen]),
      \ 'source': s:Source(a:query),
      \ 'options': [
            \ '--no-multi',
            \ '--print-query',
            \ '--expect=enter,alt-s',
            \ '--tiebreak=begin',
            \ '--ansi',
            \ '--exact',
            \ '--inline-info',
            \ '--prompt', prompt,
            \ '--header', s:header,
            \ '--preview', printf('%s %s {} {n}', s:preview_handler, s:cache_file),
            \ '--preview-window', s:fzf_preview,
            \ ]
      \ }
  call extend(options, s:window)

  call fzf#run(fzf#wrap('hoogle', options, a:fullscreen))
endfunction


function! s:Source(query) abort
  let hoogle = printf('%s --json --count=%s %s 2> /dev/null | ', s:hoogle_path, s:count, shellescape(a:query))
  let jq_stream = "jq -cn --stream 'fromstream(1|truncate_stream(inputs))' 2> /dev/null | "
  let add_path = "jq -c '. | setpath([\"fzfhquery\"]; if .module.name == null then .item else .module.name + \" \" + .item end)' | "
  let remove_duplicates = "awk -F 'fzfhquery' '!seen[$NF]++' | "
  let save_file = 'tee ' .. s:cache_file .. ' | '
  let fzf_lines = "jq -r '.fzfhquery' | "
  let awk_orange = '{ printf "\033[33m"$1"\033[0m"; $1=""; print $0 }'
  let awk_green = '{ printf "\033[32m"$1"\033[0m"; $1=""; print $0 }'
  let colorize = printf("awk '{ if ($1 == \"package\" || $1 == \"module\") %s else %s }'", awk_orange, awk_green)
  return hoogle .. jq_stream .. add_path .. remove_duplicates .. save_file .. fzf_lines .. colorize
endfunction


function! s:Handler(bang, lines) abort
  " exit if empty for <Esc> hit
  if a:lines == [] || a:lines == ['','','']
    return
  endif

  let keypress = a:lines[1]
  if keypress ==? 'enter'
    let query = a:lines[0]
    call hoogle#run(query, a:bang)
    " fzf window on neovim version <0.5 can't start in insert mode from the previous fzf window
    if s:is_nvim && !has('nvim-0.5.0')
      call feedkeys('i', 'n')
    endif
    return
  elseif keypress ==? 'alt-s'
    let item = a:lines[2]
    let link = trim(system(printf("jq -r --arg a \"%s\" '. | select(.fzfhquery == \$a) | .url' %s",
                                \ item,
                                \ s:cache_file)))
    silent! execute printf('!%s %s &> /dev/null &', s:open_tool, shellescape(link, 1))
    call s:Message('The link was sent to a default browser')
  endif
endfunction


function! hoogle#floatwindow(lines, columns) abort
  let v_pos = float2nr((&lines - a:lines) / 2)
  let h_pos = float2nr((&columns - a:columns) / 2)
  let opts = {
      \ 'relative': 'editor',
      \ 'row': v_pos,
      \ 'col': h_pos,
      \ 'height': a:lines,
      \ 'width': a:columns,
      \ 'style': 'minimal'
      \ }
  let buf = nvim_create_buf(v:false, v:true)
  call nvim_open_win(buf, v:true, opts)
endfunction


function! s:Message(text) abort
  redraw!
  if s:enable_messages
    echohl WarningMsg
    echo 'fzf-hoogle: '
    echohl None
    echon a:text
  endif
endfunction
