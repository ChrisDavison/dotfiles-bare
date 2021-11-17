function! location_in_file#grep(file, grep)
    let file=expand(a:file)
    if !filereadable(l:file)
        echo "File not available: " . l:file
        return
    end
    exec "edit " . l:file
    call search(a:grep)
    norm zO
endfunction
