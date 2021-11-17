function grep#location(query, location) abort
    exec "silent grep " . a:query . " " . expand(a:location)
endfunction
