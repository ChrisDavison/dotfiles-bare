let s:header_regexp="^#\\+ "
if !exists("g:markdown_filename_as_header_suppress")
  let g:markdown_filename_as_header_suppress = 0
endif

function markdown#filename_as_header() abort
    let filename=expand('%:t:r')
    let as_header='# ' . text#titlecase(substitute(l:filename, '-', ' ', 'g'))
    if exists('g:markdown_filename_as_header_suppress')
        if !g:markdown_filename_as_header_suppress
            exec "norm O" . as_header
        endif
    else
        exec "norm O" . as_header
    endif
endfunction

function! markdown#find_next_reference_link() abort
    " TODO return (position, url)
    let link_re='\[\(.*\)\]\[\]'
    let pos=searchpos(l:link_re, 'n')
    if l:pos == [0, 0]
        " echom "Couldn't find reference link."
        return
    endif
    let line=getline(pos[0])
    let text=matchlist(l:line, l:link_re)[1]
    let url_re='\[' . l:text . '\]: \(.*\)'
    let posurl=searchpos(l:url_re, 'n')
    if l:posurl == [0, 0]
        " echom "Couldn't find URL for reference link."
        return
    endif
    let urlline=getline(l:posurl[0])
    let url=matchlist(l:urlline, l:url_re, l:posurl[1]-1)[1]
    return [l:pos, l:url]
endfunction

function! markdown#find_reference_link_from_anchor() abort
    " TODO return (position, url)
    let link_re='\[.*\]: \(.*\)'
    let pos=searchpos(l:link_re, 'n')
    if l:pos == [0, 0]
        " echom "Couldn't find reference link anchor."
        return
    endif
    let text=matchlist(getline(l:pos[0]), l:link_re)[1]
    return [l:pos, l:text]
endfunction


function! markdown#find_next_plain_link() abort
    " TODO return (position, url)
    let link_re='\[.*\](\(.*\))'
    let pos=searchpos(l:link_re, "n")
    if pos[:2] == [0, 0]
        " echom "Couldn't find plain link"
        return 
    endif
    let line=getline(pos[0])
    let url=matchlist(l:line, l:link_re, pos[1]-1)[1]
    return [l:pos, l:url]
endfunction

function! s:compare_link_matches(i1, i2)
    let [row1, col1] = a:i1[0]
    let [row2, col2] = a:i2[0]
    if row1 == row2
        return col1 == col2 ? 0 : col1 < col2 ? -1 : 1
    elseif row1 < row2
        return -1
    else
        return 1
    endif
endfunction

function! markdown#find_next_link() abort
    let nearest_links=filter([
                \ markdown#find_next_reference_link(), 
                \ markdown#find_reference_link_from_anchor(),
                \ markdown#find_next_plain_link()
                \ ], {_, v -> len(v) > 1})
    call sort(l:nearest_links, function("<sid>compare_link_matches"))
    return l:nearest_links[0]
endfunction

function! markdown#goto_file(split) abort
    let [next_link_pos, next_link_url]=markdown#find_next_link()
    call cursor(l:next_link_pos)
    let command = "edit "
    if a:split > 0
        if winwidth(0) > 160
            " Vertical split if we have 160 columns
            " (i.e. 2 buffers at 80 columns wide)
            let command = "vsplit "
        else
            let command = "split "
        endif
    endif
    if filereadable(l:next_link_url)
        execute "silent!" . l:command . l:next_link_url
        return [1, l:next_link_url]
    endif
    " ----
    let next_link_url_res = resolve(expand("%:p:h") . "/" . l:next_link_url)
    if filereadable(l:next_link_url_res)
        let header=matchlist(l:next_link_url_res, ".*#\(.*\)")
        execute "silent!" . l:command . l:next_link_url_res
        if len(l:header)
            let l:tidy=substitute(l:header[1], "%20", " ", "g")
            if !search("# " . l:tidy)
                echo "Couldn't find header: " . l:tidy
            end
        end
        return [1, l:next_link_url_res]
    endif
    " ----
    echom "Couldn't find valid link. Tried: " . l:next_link_url
    return [0, l:next_link_url]
endfunction

function markdown#backlinks(use_grep) abort
    " Use tail (only filename) so that relative links work
    let l:fname=expand("%:t")
    if a:use_grep
        exec "silent grep! '\\((\./)*" . l:fname . "'"
        if len(getqflist()) == 0
            exec "cclose"
        endif
    else
        call fzf#vim#grep(
        \ "rg --column --line-number --no-heading --color=always --smart-case -g '!tags' ".l:fname, 1,
        \ fzf#vim#with_preview('right:50%:hidden', '?'), 0)
    end
endfunction

function! s:first_line_from_file(filename)
    if !filereadable(a:filename)
        echom a:filename . " doesn't exist"
    endif
    let title=trim(system('head -n1 ' . a:filename))
    return substitute(l:title, "^\#\\+ \\+", "", "")
endfunction

function markdown#move_visual_selection_to_file(start, end) abort
    " Need to write to a file relative to PWD
    " but copy link relative to file of origin
    " e.g. if origin file is DIRECTORY/parentfile.md
    " need to write to DIRECTORY/childfile.md
    " but link to [child](./childfile.md)
    let filename=input("Filename: ")
    let dir_of_origin=expand('%:.:h')
    let curdir=getcwd()
    let filename_nospace=tolower(substitute(l:filename, ' ', '-', 'g')) . ".md"
    let linequery=a:start . "," . a:end
    let full_filename=l:dir_of_origin . "/" . l:filename_nospace
    silent! exec ":" . l:linequery . "w " . l:full_filename
    let text=<SID>first_line_from_file(l:full_filename)
    let link="[" . l:text . "](./" . l:filename_nospace . ")"
    silent! exec ":" . l:linequery . "d"
    write
    let @+=l:link
    echo "Link copied to clipboard."
    exec "edit " . l:full_filename
    call markdown#promote_till_l1()
    exec "edit #"
endfunction

function markdown#previous_heading_linum()
    let curline=line(".")
    let heading_line=search(s:header_regexp, "nb")
    return min([l:curline, l:heading_line])
endfunction

function markdown#next_heading_linum()
    let curline=line(".")
    let heading_line=search(s:header_regexp, "n")
    return max([l:curline, l:heading_line])
endfunction

function markdown#on_heading()
    return match(getline("."), s:header_regexp) == 0
endfunction

function markdown#new_section(levels_to_add) abort
    if markdown#on_heading()
        let headerdepth=strlen(split(getline("."), " ")[0])
    else
        let headerdepth=strlen(split(getline(markdown#previous_heading_linum()), " ")[0])
    endif

    if markdown#next_heading_linum() == line(".") " if we're the last heading
        let insert_pos = line("$")                " insert at end of doc
    else
        let insert_pos = markdown#next_heading_linum() - 1  " otherwise, before next heading
    endif

    let markers=repeat("#", l:headerdepth + a:levels_to_add) . " "
    call append(l:insert_pos, ["", l:markers, ""])
    call cursor(l:insert_pos + 2, 1)
    startinsert!
endfunction

function markdown#header_increase() abort
    let save_cursor = getcurpos()
    exec "silent %s/^\\(#\\+\\)/\\1#/"
    call setpos('.', l:save_cursor)
endfunction

function markdown#header_decrease() abort
    let save_cursor = getcurpos()
    exec "silent %s/^\\(#\\+\\)#/\\1/"
    call setpos('.', l:save_cursor)
endfunction

function markdown#jump_to_heading(location) abort
    exec "edit " . expand(a:location)
    BLines ^\#\+[ ]
endfunction

function markdown#file_headers(location)
    let filename=expand(a:location)
    let headers=filter(copy(readfile(l:filename)), {idx, val -> match(val, s:header_regexp) >= 0})
    return l:headers
endfunction

function markdown#goto_previous_heading()
    call setpos('.', [0, markdown#previous_heading_linum(), 1, 0])
endfunction

function markdown#goto_next_heading()
    call setpos('.', [0, markdown#next_heading_linum(), 1, 0])
endfunction


function markdown#choose_header(location)
    let headers=markdown#file_headers(a:location)
    let choice=inputlist(map(headers, {idx, val -> idx . ". " . val}))
    let chosen_title=headers[l:choice]
    return l:chosen_title
endfunction

function markdown#lowest_header_level()
    let has_l1=search("^# ", "n") > 0
    let has_l2=search("^## ", "n") > 0
    let has_l3=search("^### ", "n") > 0
    let has_l4=search("^#### ", "n") > 0
    if has_l1
        return 1
    elseif has_l2
        return 2
    elseif has_l3
        return 3
    elseif has_l4
        return 4
    else
        return 0
    end
endfunction

function markdown#promote_till_l1()
    let to_replace=repeat("#", markdown#lowest_header_level())
    exec "%s/" . l:to_replace . " /# /g"
    write
endfunction
