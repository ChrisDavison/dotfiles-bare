let md_equalprg = "pandoc --to markdown+smart-simple_tables+pipe_tables-shortcut_reference_links --markdown-headings=atx --standalone"

" === Decide whether to wrap or not
let md_equalprg .= " --columns=80 --wrap=auto"
" let md_equalprg .= " --wrap=none"

" === Decide whether to use reference links or not
let md_equalprg .= " --reference-links"
" let md_equalprg .= " --reference-links --reference-location=section"

let &l:equalprg=md_equalprg

let g:coc_suggest_disable=1

let g:pandoc#keyboard#use_default_mappings=0
let g:pandoc#formatting#mode='hA'
let g:pandoc#formatting#smart_autoformat_on_cursormoved=0
let g:pandoc#formatting#equalprg=md_equalprg
let g:pandoc#formatting#extra_equalprg=''
let g:pandoc#folding#fdc=0
let g:pandoc#folding#fold_fenced_codeblocks=1
let g:pandoc#syntax#conceal#use=1
let g:pandoc#syntax#conceal#urls=1
let g:pandoc#spell#enabled=0
let g:pandoc#toc#position="left"
let g:pandoc#toc#close_after_navigating=0
let g:goyo_width=82
let g:pandoc#syntax#codeblocks#embeds#langs=[
    \ "python",
    \ "bash",
    \ "sql",
    \ "go",
    \ "rust"
  \ ]

setlocal noautoindent
setlocal nospell
setlocal conceallevel=2
setlocal formatoptions+=a 
setlocal formatoptions+=n
setlocal textwidth=0   " don't wrap at 80
setlocal foldmethod=expr
setlocal foldexpr=g:pandoc#folding#FoldExpr()

" Defined in ~/.vim/autoload/markdown.vim
command! -bang Backlinks call markdown#backlinks(<bang>1)
command! FilenameAsHeader call markdown#filename_as_header()
command! HeaderDecrease call markdown#header_decrease()
command! HeaderIncrease call markdown#header_increase()

command! CheckboxForward s/\[ \]/**[»]**/

command! -range MoveVisualToFile call markdown#move_visual_selection_to_file(<line1>, <line2>)
" command! Headings :BLines ^#\+
command! Headings :silent grep ^\#\+  %

command! Hashtags :exec "!hashtags " . expand("%")

function! s:try_file_or_firefox(split) abort
    let [worked, url] = markdown#goto_file(a:split)
    if worked == 0
        echom "Link to file didn't work. assuming url: " . l:url
        exec ":!firefox --new-tab '" . l:url . "'"
    endif
endfunction

vnoremap <buffer> <leader>w :MoveVisualToFile<CR>
nnoremap <buffer> gf :silent!call <sid>try_file_or_firefox(0)<CR>
nnoremap <buffer> gs :silent!call <sid>try_file_or_firefox(1)<CR>
nnoremap <leader>S :call markdown#new_section(1)<CR>
nnoremap <leader>i :Headings<CR>

nnoremap <buffer> ]] :call markdown#goto_next_heading()<CR>
nnoremap <buffer> [[ :call markdown#goto_previous_heading()<CR>

vmap <buffer> aS <Plug>(pandoc-keyboard-select-section-inclusive)
omap <buffer> aS :normal VaS<CR>
vmap <buffer> iS <Plug>(pandoc-keyboard-select-section-exclusive)
omap <buffer> iS :normal ViS<CR>

nnoremap <buffer> FF f(lyt):!firefox --new-tab '<C-r>"'<CR>
vnoremap <buffer> FF y:!firefox --new-tab '<C-r>"'<CR>
nnoremap <buffer> FC :!firefox --new-tab '<cWORD>'<CR>

nnoremap <buffer> ml :LinkToFileFromCWord<CR>
vnoremap <buffer> ml  :<C-u>LinkToFileFromVisual<CR>
nnoremap <buffer> gml :EditFileFromCWord<CR>
vnoremap <buffer> gml :<C-u>EditFileFromVisual<CR>

nnoremap <leader>il :InsertLinkToNote

command! FmtWrap call <sid>format_maybe_wrap(1)
command! FmtNoWrap call <sid>format_maybe_wrap(0)

command! -bang Typewrite call <sid>toggle_typewrite(<bang>1)

function! s:format_maybe_wrap(wrap)
    let oldequal=&equalprg

    let md_equalprg="pandoc --to markdown+smart-simple_tables+pipe_tables-shortcut_reference_links --markdown-headings=atx --standalone --reference-links --reference-location=section"

    if a:wrap == 1
       let md_equalprg .= " --columns=80 --wrap=auto"
    else
        let md_equalprg .= " --wrap=none"
    endif

    let &l:equalprg=md_equalprg
    norm mz
    norm g0=G`zmz
    let &l:equalprg=oldequal
endfunction

function! s:toggle_typewrite(activate)
    if a:activate == 1
        nnoremap j gjzz
        nnoremap k gkzz
    else
        nnoremap j gj
        nnoremap k gk
    endif
endfunction

" pandocCiteKey is the WORD of my @tag
" pandocCiteAnchor is the '@'
if g:colors_name=="melange" 
    highlight pandocCiteKey guifg=#e8040c
    highlight pandocCiteAnchor guifg=#e86e04
elseif g:colors_name=="edge"
    highlight pandocCiteKey guifg=#ba3eef
    highlight pandocCiteAnchor guifg=#ef3ecc
else
endif

set norelativenumber
