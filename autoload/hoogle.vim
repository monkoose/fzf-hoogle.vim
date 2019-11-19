let s:cpo_save = &cpo
set cpo&vim

" ----------------------------------------------------------
" Options
" ----------------------------------------------------------

let s:preview_height = get(g:, "hoogle_preview_height", 22)

if has('nvim')
  let s:window = get(g:, "hoogle_fzf_window", {"window": "call hoogle#floatwindow(40, 150)"})
else
  let s:window = get(g:, "hoogle_fzf_window", {"down": "50%"})
endif

let s:file = get(g:, "hoogle_tmp_file", "/tmp/hoogle-query.json")
let s:hoogle_path = get(g:, "hoogle_path", "hoogle")
let s:header = get(g:, "hoogle_fzf_header", printf("\x1b[35m%s\x1b[m", 'enter') . ' - research with query :: ' . printf("\x1b[35m%s\x1b[m", 'alt-s') . " - source code\n ")
let s:fzf_preview = get(g:, "hoogle_fzf_preview", "right:60%:wrap")
let s:bin_dir = expand('<sfile>:h:h') . '/bin/'
let s:bin = {
      \ 'preview': s:bin_dir . 'preview.sh',
      \ }

" ----------------------------------------------------------
" Utility functions
" ----------------------------------------------------------

let s:html_entities = {
      \ 'nbsp':     160, 'iexcl':    161, 'cent':     162, 'pound':    163,
      \ 'curren':   164, 'yen':      165, 'brvbar':   166, 'sect':     167,
      \ 'uml':      168, 'copy':     169, 'ordf':     170, 'laquo':    171,
      \ 'not':      172, 'shy':      173, 'reg':      174, 'macr':     175,
      \ 'deg':      176, 'plusmn':   177, 'sup2':     178, 'sup3':     179,
      \ 'acute':    180, 'micro':    181, 'para':     182, 'middot':   183,
      \ 'cedil':    184, 'sup1':     185, 'ordm':     186, 'raquo':    187,
      \ 'frac14':   188, 'frac12':   189, 'frac34':   190, 'iquest':   191,
      \ 'Agrave':   192, 'Aacute':   193, 'Acirc':    194, 'Atilde':   195,
      \ 'Auml':     196, 'Aring':    197, 'AElig':    198, 'Ccedil':   199,
      \ 'Egrave':   200, 'Eacute':   201, 'Ecirc':    202, 'Euml':     203,
      \ 'Igrave':   204, 'Iacute':   205, 'Icirc':    206, 'Iuml':     207,
      \ 'ETH':      208, 'Ntilde':   209, 'Ograve':   210, 'Oacute':   211,
      \ 'Ocirc':    212, 'Otilde':   213, 'Ouml':     214, 'times':    215,
      \ 'Oslash':   216, 'Ugrave':   217, 'Uacute':   218, 'Ucirc':    219,
      \ 'Uuml':     220, 'Yacute':   221, 'THORN':    222, 'szlig':    223,
      \ 'agrave':   224, 'aacute':   225, 'acirc':    226, 'atilde':   227,
      \ 'auml':     228, 'aring':    229, 'aelig':    230, 'ccedil':   231,
      \ 'egrave':   232, 'eacute':   233, 'ecirc':    234, 'euml':     235,
      \ 'igrave':   236, 'iacute':   237, 'icirc':    238, 'iuml':     239,
      \ 'eth':      240, 'ntilde':   241, 'ograve':   242, 'oacute':   243,
      \ 'ocirc':    244, 'otilde':   245, 'ouml':     246, 'divide':   247,
      \ 'oslash':   248, 'ugrave':   249, 'uacute':   250, 'ucirc':    251,
      \ 'uuml':     252, 'yacute':   253, 'thorn':    254, 'yuml':     255,
      \ 'OElig':    338, 'oelig':    339, 'Scaron':   352, 'scaron':   353,
      \ 'Yuml':     376, 'circ':     710, 'tilde':    732, 'ensp':    8194,
      \ 'emsp':    8195, 'thinsp':  8201, 'zwnj':    8204, 'zwj':     8205,
      \ 'lrm':     8206, 'rlm':     8207, 'ndash':   8211, 'mdash':   8212,
      \ 'lsquo':   8216, 'rsquo':   8217, 'sbquo':   8218, 'ldquo':   8220,
      \ 'rdquo':   8221, 'bdquo':   8222, 'dagger':  8224, 'Dagger':  8225,
      \ 'permil':  8240, 'lsaquo':  8249, 'rsaquo':  8250, 'euro':    8364,
      \ 'fnof':     402, 'Alpha':    913, 'Beta':     914, 'Gamma':    915,
      \ 'Delta':    916, 'Epsilon':  917, 'Zeta':     918, 'Eta':      919,
      \ 'Theta':    920, 'Iota':     921, 'Kappa':    922, 'Lambda':   923,
      \ 'Mu':       924, 'Nu':       925, 'Xi':       926, 'Omicron':  927,
      \ 'Pi':       928, 'Rho':      929, 'Sigma':    931, 'Tau':      932,
      \ 'Upsilon':  933, 'Phi':      934, 'Chi':      935, 'Psi':      936,
      \ 'Omega':    937, 'alpha':    945, 'beta':     946, 'gamma':    947,
      \ 'delta':    948, 'epsilon':  949, 'zeta':     950, 'eta':      951,
      \ 'theta':    952, 'iota':     953, 'kappa':    954, 'lambda':   955,
      \ 'mu':       956, 'nu':       957, 'xi':       958, 'omicron':  959,
      \ 'pi':       960, 'rho':      961, 'sigmaf':   962, 'sigma':    963,
      \ 'tau':      964, 'upsilon':  965, 'phi':      966, 'chi':      967,
      \ 'psi':      968, 'omega':    969, 'thetasym': 977, 'upsih':    978,
      \ 'piv':      982, 'bull':    8226, 'hellip':  8230, 'prime':   8242,
      \ 'Prime':   8243, 'oline':   8254, 'frasl':   8260, 'weierp':  8472,
      \ 'image':   8465, 'real':    8476, 'trade':   8482, 'alefsym': 8501,
      \ 'larr':    8592, 'uarr':    8593, 'rarr':    8594, 'darr':    8595,
      \ 'harr':    8596, 'crarr':   8629, 'lArr':    8656, 'uArr':    8657,
      \ 'rArr':    8658, 'dArr':    8659, 'hArr':    8660, 'forall':  8704,
      \ 'part':    8706, 'exist':   8707, 'empty':   8709, 'nabla':   8711,
      \ 'isin':    8712, 'notin':   8713, 'ni':      8715, 'prod':    8719,
      \ 'sum':     8721, 'minus':   8722, 'lowast':  8727, 'radic':   8730,
      \ 'prop':    8733, 'infin':   8734, 'ang':     8736, 'and':     8743,
      \ 'or':      8744, 'cap':     8745, 'cup':     8746, 'int':     8747,
      \ 'there4':  8756, 'sim':     8764, 'cong':    8773, 'asymp':   8776,
      \ 'ne':      8800, 'equiv':   8801, 'le':      8804, 'ge':      8805,
      \ 'sub':     8834, 'sup':     8835, 'nsub':    8836, 'sube':    8838,
      \ 'supe':    8839, 'oplus':   8853, 'otimes':  8855, 'perp':    8869,
      \ 'sdot':    8901, 'lceil':   8968, 'rceil':   8969, 'lfloor':  8970,
      \ 'rfloor':  8971, 'lang':    9001, 'rang':    9002, 'loz':     9674,
      \ 'spades':  9824, 'clubs':   9827, 'hearts':  9829, 'diams':   9830,
      \ 'apos':      39}

function! s:HtmlDecode(str) abort
  let str = substitute(a:str, "<[^>]*>", "", "g")
  let str = substitute(str,'\c&#\%(0*38\|x0*26\);','&amp;','g')
  let str = substitute(str,'\c&#\(\d\+\);','\=nr2char(submatch(1))','g')
  let str = substitute(str,'\c&#\(x\x\+\);','\=nr2char("0".submatch(1))','g')
  let str = substitute(str,'\c&apos;',"'",'g')
  let str = substitute(str,'\c&quot;','"','g')
  let str = substitute(str,'\c&gt;','>','g')
  let str = substitute(str,'\c&lt;','<','g')
  let str = substitute(str,'\C&\(\%(amp;\)\@!\w*\);','\=nr2char(get(s:html_entities,submatch(1),63))','g')
  return substitute(str,'\c&amp;','\&','g')
endfunction

function! s:UrlDecode(str) abort
  let str = substitute(substitute(substitute(a:str,'%0[Aa]\n$','%0A',''),'%0[Aa]','\n','g'),'+',' ','g')
  return iconv(substitute(str,'%\(\x\x\)','\=nr2char("0x".submatch(1))','g'), 'utf-8', 'latin1')
endfunction

function! s:UrlEencode(str) abort
  return substitute(iconv(a:str, 'latin1', 'utf-8'),'[^A-Za-z0-9_.~-]','\="%".printf("%02X",char2nr(submatch(0)))','g')
endfunction

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
    let new_search = 'Hoogle ' . query
    execute new_search
    " fzf on neovim for some reason can't start in insert mode from previous fzf window
    " there is workaround for this
    if has('nvim')
      call feedkeys('i', 'n')
    endif
  elseif keypress ==? 'alt-s'
    let item = a:lines[2]
    let link = system(printf("jq -r --arg a \"%s\" '. | select(.fzfhquery == \$a) | .url' %s", item, s:file))
    call s:PreviewSourceCode("hoogle", link)
  endif
endfunction

function! s:PreviewSourceCode(name, link) abort
  let response = "-- There is no source for this item"
  let linenr = 1
  let preview_height = 4
  if a:link =~ '#'
    let [page, anchor] = split(a:link, '#')
    let source_head = split(page, "/docs/")[0]
    echo "Downloading source file. Please wait..."
    let source_tail = system("curl -sL " . page . " | grep -oP 'id=\"". trim(anchor) . "\".*?class=\"link\"' | sed 's/^.*href=\"\\(.*\\)\" class=\"link\"/\\1/'")
    let source_link = trim(source_head . "/docs/" . source_tail)
    if source_link =~ '#'
      let [source_page, source_anchor] = split(source_link, '#')
      let source_anchor = s:UrlEencode(s:UrlDecode(source_anchor))
      let response = system("curl -sL " . source_page)
      let linenr = substitute(response, '.*name="line-\(\d\+\)".*name="' . source_anchor . '".*', '\1', "")
      let response = s:HtmlDecode(response)
      let preview_height = s:preview_height
    endif
  endif
  pclose
  let open_preview = 'silent! pedit +setlocal\ ' .
                \ 'buftype=nofile\ nobuflisted\ ' .
                \ 'noswapfile\ bufhidden=wipe\ ' .
                \ 'filetype=hoogle\ syntax=haskell ' . a:name
  execute open_preview
  execute "normal! \<C-w>P"
  nnoremap <silent><buffer> q <C-w>P:pclose<CR>
  execute "silent! 0put =response"
  execute "resize " . preview_height
  call cursor(linenr, 1)
  execute "normal z\<CR>"
  execute "redraw!"
  setlocal cursorline
  setlocal nomodifiable
endfunction

function! s:Source(hoogle, file, query) abort
let add_path = printf("jq -c '. | %s'", 'setpath(["fzfhquery"]; if .module.name == null then .item else .module.name + " " + .item end)')
let jq_stream = "jq -cn --stream 'fromstream(1|truncate_stream(inputs))' 2> /dev/null"
return printf(
      \ "%s --json %s 2> /dev/null | %s | head -n 1000 | %s | " .
          \ "awk -F 'fzfhquery' '!seen[$NF]++' | tee %s | jq -r '.fzfhquery' | " .
          \ "awk '{ if ($1 == \"package\" || $1 == \"module\") { printf \"\033[33m\"$1\"\033[0m\"; $1=\"\"; print $0}" .
              \ "else { printf \"\033[32m\"$1\"\033[0m\"; $1=\"\"; print $0 }}'",
      \ a:hoogle,
      \ shellescape(a:query),
      \ jq_stream,
      \ add_path,
      \ a:file,
      \ )
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
  let options = {
      \ 'sink*': function('s:Handler'),
      \ 'source': s:Source(s:hoogle_path, s:file, a:query),
      \ 'options': [
            \ '--no-multi',
            \ '--print-query',
            \ '--expect=enter,alt-s',
            \ '--tiebreak=begin',
            \ '--ansi',
            \ '--exact',
            \ '--inline-info',
            \ '--prompt',
            \ 'hoogle ' . a:query . '> ',
            \ '--header', s:header,
            \ '--preview', shellescape(s:bin.preview) . ' ' . s:file . ' {} {n}',
            \ '--preview-window', s:fzf_preview,
            \ ]
      \ }
    call extend(options, s:window)
  call fzf#run(fzf#wrap(
    \ 'hoogle',
    \ options,
    \ a:fullscreen
    \ ))
endfunction

" ----------------------------------------------------------
let &cpo = s:cpo_save
unlet s:cpo_save

