" ----------------------------------------------------------
" Options
" ----------------------------------------------------------

let s:hoogle_path = get(g:, "hoogle_path", "hoogle")
let s:preview_height = get(g:, "hoogle_preview_height", 22)

if has('nvim')
  let s:window = get(g:, "hoogle_fzf_window", {"window": "call hoogle#floatwindow(40, 150)"})
else
  let s:window = get(g:, "hoogle_fzf_window", {"down": "50%"})
endif

let s:count = get(g:, "hoogle_count", 500)
let s:header = get(g:, "hoogle_fzf_header",
      \ printf("\x1b[35m%s\x1b[m", 'enter') .. ' - research with query :: ' ..
      \ printf("\x1b[35m%s\x1b[m", 'alt-s') .. " - source code\n ")
let s:fzf_preview = get(g:, "hoogle_fzf_preview", "right:60%:wrap")
let s:open_tool = get(g:, "hoogle_open_link", executable("xdg-open") ? "xdg-open" : "")
" Cache only documentation pages, because source code pages rarely exceed 500K
let s:allow_cache = get(g:, "hoogle_allow_cache", 1)
let s:cache_dir = get(g:, "hoogle_cache_dir", $HOME .. "/.cache/fzf-hoogle/")
if !isdirectory(s:cache_dir)
  call mkdir(s:cache_dir, "p")
endif
let s:file = s:cache_dir .. 'query.json'
let s:source_file = s:cache_dir .. 'source.html'
let s:cacheable_size = get(g:, "hoogle_cacheable_size", 500) * 1000

let s:bin_dir = expand('<sfile>:h:h') .. '/bin/'
let s:bin = {
      \ 'preview': s:bin_dir .. 'preview.sh',
      \ }

" ----------------------------------------------------------
" Hoogle
" ----------------------------------------------------------

function! s:Handler(lines) abort
  " exit if empty for <Esc> hit
  if a:lines == [] || a:lines == ['','','']
    return
  endif

  let keypress = a:lines[1]
  if keypress ==? 'enter'
    let query = a:lines[0]
    let new_search = 'Hoogle ' .. query
    execute new_search
    " fzf on neovim for some reason can't start in insert mode from previous fzf window
    " there is workaround for this
    if has('nvim')
      call feedkeys('i', 'n')
    endif
  elseif keypress ==? 'alt-s'
    let item = a:lines[2]
    let link = system(printf("jq -r --arg a \"%s\" '. | select(.fzfhquery == \$a) | .url' %s", item, s:file))
    call s:PreviewSourceCode(link)
  endif
endfunction


function! s:GetSourceTail(page, anchor, file_tail) abort
  " A lot of trim() because system() produce unwanted NUL ^@ and some other space characters.
  " Not sure if it is the best way to get rid of them
  let anchor = trim(a:anchor)
  let download_message = "Downloading source file. Please wait..."
  let curl_get = "curl -sL -m 10 " .. a:page .. " | "
  let line_with_anchor = "grep -oP 'id=\"" .. anchor .. "\".*?class=\"link\"' "
  " Sometimes there more then one link for anchor so more then one line from grep
  let first_line = "| head -n 1 | "
  let strip_to_link = "sed 's/^.*href=\"\\(.*\\)\" class=\"link\"/\\1/'"

  if !s:allow_cache || a:page !~ '^http'
    echo download_message
    return trim(system(curl_get .. line_with_anchor .. first_line .. strip_to_link))
  endif

  let file_path = glob(s:cache_dir .. "*" .. "==" .. a:file_tail)
  let file_exists = file_path != ""
  let page_headers = system("curl -sIL " .. a:page)
  let etag = matchstr(page_headers, 'ETag: "\zs\w\+\ze"')

  if file_exists
    let file_etag = matchstr(file_path, '/\zs\w\+\ze==')
    if etag ==# file_etag
      echo "Opening source file..."
      return trim(system(line_with_anchor .. file_path .. first_line .. strip_to_link))
    else
      call delete(file_path)
    endif
  endif

  let content_size = matchstr(page_headers, 'Content-Length: \zs\d\+\ze')
  echo download_message
  if content_size < s:cacheable_size
    return trim(system(curl_get .. line_with_anchor .. first_line .. strip_to_link))
  endif

  let save_file  = "tee " .. s:cache_dir .. etag .. "==" .. a:file_tail .. " | "
  return trim(system(curl_get .. save_file .. line_with_anchor .. first_line .. strip_to_link))
endfunction


function! s:Response(request) abort
  echo "Locating source file..."
  let response = {}
  let [page, anchor] = split(a:request, '#')
  let [source_head, file_tail] = split(page, "/docs/")
  let source_tail = s:GetSourceTail(page, anchor, file_tail)
  let source_link = source_head .. "/docs/" .. source_tail
  if source_link =~ '#'
    let [source_page, source_anchor] = split(source_link, '#')
    let source_anchor = hoogle#url#encode(hoogle#url#decode(source_anchor))
    let text =  system("curl -sL -m 10 " .. source_page .. " | tee " .. s:source_file)
    let linenr = system(printf("grep 'name=\"%s\"' %s", source_anchor, s:source_file))
    " Some pages don't have anchor tag for line-xx or proper anchor
    if match(linenr, 'a name="line-\d\+"') != -1
      let response.linenr = matchstr(linenr, 'name="line-\zs\d\+\ze"')
    endif
    let response.text = hoogle#url#htmldecode(text)
    let response.preview_height = s:preview_height
    let response.module_name = matchstr(source_tail, 'src/\zs.\{-1,}\ze\.html#')
  endif
  return response
endfunction


function! s:PreviewSourceCode(link) abort
  " We can only get source link from request that have anchor
  " so for module and package items just open default browser with a link
  if a:link !~ '#'
    if s:open_tool != ""
      silent execute "!" .. s:open_tool .. " " .. a:link
    endif
    return
  endif

  let response = s:Response(a:link)
  let source_text = get(response, "text", "-- There is no source for this item")

  pclose
  execute 'silent! pedit +setlocal\ buftype=nofile\ nobuflisted\ ' ..
          \ 'noswapfile\ bufhidden=wipe\ filetype=hoogle\ syntax=haskell ' ..
          \ get(response, "module_name", "hoogle")

  execute "normal! \<C-w>P"
  execute "silent! 0put =source_text"
  execute "resize " .. get(response, "preview_height", s:preview_height)
  call cursor(get(response, "linenr", 1), 1)
  execute "normal z\<CR>"
  execute "redraw!"
  nnoremap <silent><buffer> q <C-w>P:pclose<CR>
  setlocal cursorline
  setlocal nomodifiable
endfunction


function! s:Source(query) abort
  let hoogle = printf("%s --json %s 2> /dev/null | ", s:hoogle_path, shellescape(a:query))
  let jq_stream = "jq -cn --stream 'fromstream(1|truncate_stream(inputs))' 2> /dev/null | "
  let items_number = "head -n " .. s:count .. " | "
  let add_path = "jq -c '. | setpath([\"fzfhquery\"]; if .module.name == null then .item else .module.name + \" \" + .item end)' | "
  let remove_duplicates = "awk -F 'fzfhquery' '!seen[$NF]++' | "
  let save_file = "tee " .. s:file .. " | "
  let fzf_lines = "jq -r '.fzfhquery' | "
  let awk_orange = "{ printf \"\033[33m\"$1\"\033[0m\"; $1=\"\"; print $0}"
  let awk_green = "{ printf \"\033[32m\"$1\"\033[0m\"; $1=\"\"; print $0 }"
  let colorize = "awk '{ if ($1 == \"package\" || $1 == \"module\") " .. awk_orange .. "else " .. awk_green .. "}'"
  return hoogle .. jq_stream .. items_number .. add_path .. remove_duplicates .. save_file .. fzf_lines .. colorize
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


function! hoogle#run(query, fullscreen) abort
  if strdisplaywidth(a:query) > 30
    let prompt = a:query[:27] .. '.. > '
  else
    let prompt = a:query .. ' > '
  endif

  let options = {
      \ 'sink*': function('s:Handler'),
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
            \ '--preview', shellescape(s:bin.preview) .. ' ' .. s:file .. ' {} {n}',
            \ '--preview-window', s:fzf_preview,
            \ ]
      \ }
  call extend(options, s:window)

  call fzf#run(fzf#wrap('hoogle', options, a:fullscreen ))
endfunction
