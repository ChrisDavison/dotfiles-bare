function text#titlecase(str) abort
    let words=split(a:str, '\W\+')
    let titled=map(l:words, {_, word -> toupper(word[0]) . word[1:]})
    return join(l:titled, ' ')
endfunction

function text#prompt_for_filename(dir, split, ...) abort
    let projectname=input('Title: ')
    let project_nospace=substitute(l:projectname, ' ', '-', 'g')
    let filepath=a:dir . l:project_nospace . '.md'
    let tags=a:000
    if a:split
        split
    endif
    exec ':edit ' . l:filepath
    call append(0, '# ' . text#titlecase(l:projectname))
    if !empty(l:tags)
        let tags=map(copy(l:tags), '"@" . v:val')
        call append(1, ['', join(l:tags, " ")])
    endif
endfunction
