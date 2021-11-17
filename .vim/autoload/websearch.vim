function websearch#cmd()
    " Windows WSL
    if has_key(environ(), "BROWSER")
        return environ()["BROWSER"]
    else if wsl#is_wsl()
        return "cmd.exe /c start /b"
    " Windows
    elseif executable('cmd.exe')
        return "start /b explorer"
    " Linux/BSD
    elseif executable("xdg-open")
        return "xdg-open"
    " MacOS
    elseif executable("open")
        return "open"
    endif
endfunction

function websearch#websearch(template, query)
    let url=shellescape(a:template . a:query)
    echo l:url
    call system(websearch#cmd() . " " . l:url)
endfunction

function websearch#duckduckgo(query)
    call websearch#websearch("https://duckduckgo.com/?q=", a:query)
endfunction

function websearch#youtube(query)
    call websearch#websearch("https://www.youtube.com/results?search_query=", a:query)
endfunction

function websearch#devdocs(query)
    call websearch#websearch("https://devdocs.io/\\\\#q=", a:query)
endfunction

function websearch#cpp(query)
    call websearch#websearch("https://cplusplus.com/search.do?q=", a:query)
endfunction

