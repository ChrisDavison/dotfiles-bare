" function! myfuncs#get_journals(year, month) abort
"     let root=myfuncs#journal_dir()
"     let year=strftime("%Y")
"     let month=a:month
"     if a:month != ""
"         let month= "**"
"     else
"     let path= 
" endfunction

function! myfuncs#journal_dir() abort
    let root=expand("~/notes/journal/")
    if exists("g:journal_root")
        let root=&g:journal_root
    elseif exists("g:knowledge_dir")
        let root=g:knowledge_dir . "journal/"
    else
        echom "Assuming journal dir is " . l:root
    endif
    if match(l:root, "/$")
        let root = root[:-2]
    endif
    return l:root
endfunction

function! myfuncs#n_days_journals(n) abort
    let folder=expand(myfuncs#journal_dir())
    if !isdirectory(l:folder)
        echom "Not a folder..." . l:folder
        return
    endif
    let files=split(glob(l:folder . "/*.md"), "\n")
    let dates=map(myfuncs#last_n_days(a:n), {_, val -> substitute(val, "-", "", "g")})
    let pattern=join(l:dates, "\\|")
    let files=filter(l:files, {_, val -> match(val, l:pattern) >= 0})
    return reverse(l:files)
endfunction

function! myfuncs#n_days_journals_fzf(n) abort
    call fzf#run(fzf#wrap({'source': myfuncs#n_days_journals(a:n)}))
endfunction


function! myfuncs#n_days_journals_quickfix(n) abort
    let files_as_qflist=map(myfuncs#n_days_journals(a:n), {key, val -> {'filename': join(split(trim(v:val, ' '), " ")[1:], ' '), 'lnum': 1, 'col': 1}})
    call setqflist(l:files_as_qflist[1:a:n])
endfunction

function! myfuncs#new_journal(topic) abort
    if len(a:topic) != 0
        let topic=a:topic
    else
        let topic=input("TOPIC: ")
    endif
    let journal_format="/%Y%m%dT%H%M"
    let fmt="journal/" . l:journal_format
    call vim_datedfiles#new_with_fmt_and_name(g:knowledge_dir, l:fmt, l:topic)
    call append(1, ["", "@journal"])
    norm G
endfunction

function! myfuncs#new_logbook()
    exec "DatedFileWithFmt " . expand(g:knowledge_dir) . "work/logbook %Y/%Y-%m-%d"
endfunction

function! myfuncs#other_logbook(delta)
    let date=myfuncs#relative_date(a:delta)
    let year=split(l:date, "-")[0]
    exec "DatedFileWithFmt " . expand(g:knowledge_dir) . "work/logbook/" . l:year . "/" . l:date . ".md"
endfunction

function! myfuncs#last_7_logbooks_in_vsplit() abort
    let thisyear="~/notes/work/logbook/" . strftime("%Y") . "/"
    let today=strftime("%Y-%m-%d.md")
    let lbs=directory_files#last_n_in_dir(l:thisyear, 8)[:-1]
    let not_today_lbs=filter(l:lbs, 'v:val !~ "' . l:today . '"')
    let last7=l:not_today_lbs[-7:]
    call scratch#new("last7logbooks.md")
    setlocal modifiable noreadonly noswapfile bufhidden=hide buftype=nofile
    exec ":norm ggdG"
    for var in last7
        exec ":r " . expand(var)
        call append(line('$'), ["",""])
    endfor
    setlocal filetype=markdown nomodifiable readonly
endfunction

function! myfuncs#copen_last_7_logbooks() abort
    let thisyear="~/notes/work/logbook/" . strftime("%Y") . "/"
    let today=strftime("%Y-%m-%d.md")
    let lbs=systemlist("ls " . thisyear)
    let not_today_lbs=filter(l:lbs, 'v:val !~ "' . l:today . '"')
    let last7=l:not_today_lbs[-7:]
    let last7_as_qf=map(last7, {key, val -> {
                \ 'filename': expand(l:thisyear . v:val), 
                \ 'lnum': 3, 'col': 1, 
                \ 'text': strftime("%a %d %B", strptime('%Y-%m-%d', v:val))}})
    call setqflist(last7_as_qf)
    copen
    cfirst
endfunction

function! myfuncs#large_notes_as_quickfix(n) abort
    let files=systemlist("wc -w ~/notes/**/*.md | grep -v 'logbook' | sort -rn")
    let files_as_qflist=map(l:files, {key, val -> {'filename': join(split(trim(v:val, ' '), " ")[1:], ' '), 'lnum': 1, 'col': 1, 'text': split(trim(val, ' '), " ")[0] . " words"}})
    call setqflist(l:files_as_qflist[1:a:n])
endfunction

function! myfuncs#relative_date(delta)
    return trim(system("date -d '" . a:delta . "days' '+%F'"))
endfunction

function! myfuncs#last_n_days(n) abort
    let dates=[]
    for delta in range(-a:n+1, 0)
        call add(l:dates, myfuncs#relative_date(l:delta))
    endfor
    return l:dates
endfunction


function! myfuncs#capture_inbox(message) abort
    let filepath = expand(g:knowledge_dir . "inbox.md")
    let lines = readfile(l:filepath)
    let start_of_list = match(l:lines, "^- ")
    let end_of_list = match(l:lines, "^[^-]*$", l:start_of_list)
    let message = substitute(a:message, "^- +", "", "")
    if l:start_of_list == -1
        call insert(l:lines,  "", 1)
        call insert(l:lines, "- " . l:message, 2)
    else
        call insert(l:lines,  "- " . l:message, l:end_of_list)
    endif
    call writefile(l:lines, l:filepath)
endfunction

function! myfuncs#set_codelens_colours()
    if g:colors_name == g:dark_scheme
        hi CocCodeLens guifg=White
        hi CocHintSign guifg=#505050
    else
       hi CocCodeLens guifg=White
        hi CocHintSign guifg=#dedede
    endif
endfunction

function! myfuncs#format_and_return_to_mark() abort
    call setpos("'z", [bufnr(), line('.'), col('.'), 0])
    norm gg=G
    call setpos(".", getpos("'z"))
    norm zz
    delmarks z
endfunction

