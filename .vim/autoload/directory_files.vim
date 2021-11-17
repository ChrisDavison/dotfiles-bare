function directory_files#last_file_in_dir(dir) abort
    let fname=fnamemodify(a:dir, ':p') . "*"
    let files=glob(l:fname, 0, 1)
    if len(l:files) > 0
        return l:files[len(l:files)-1]
    else
        echom "No matching files"
    endif
endfunction

function directory_files#last_n_in_dir(dir, n) abort
    let fname=fnamemodify(a:dir, ":p") . "*"
    let files = glob(l:fname, 0, 1)[-a:n:]
    return l:files
endfunction

function directory_files#quickfix_last_7_in_dir(dir) abort
    let files=directory_files#last_n_in_dir(a:dir, 7)
    let last7_as_qf=map(l:files, {key, val -> {'filename':  v:val, 'lnum': 3, 'col': 1}})
    call setqflist(last7_as_qf)
    cw
endfunction
