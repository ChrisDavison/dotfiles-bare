function wsl#is_wsl() abort
    if has_key(environ(), "WSL_HOST_IP")
        return 1
    elseif has_key(environ(), "IS_WSL") && environ()["IS_WSL"]
        return 1
    else
        return 0
    endif
endfunction

function wsl#setup_clipboard() abort
    if !wsl#is_wsl()
        return
    endif
    let g:clipboard = {
            \   'name': 'win32yank-wsl',
            \   'copy': {
            \      '+': '/usr/local/bin/win32yank -i --crlf',
            \      '*': '/usr/local/bin/win32yank -i --crlf',
            \    },
            \   'paste': {
            \      '+': '/usr/local/bin/win32yank -o --lf',
            \      '*': '/usr/local/bin/win32yank -o --lf',
            \   },
            \   'cache_enabled': 0,
            \ }
endfunction

function wsl#setup() abort
    if !wsl#is_wsl()
        return
    endif
    call wsl#setup_clipboard()
    " let g:netrw_browsex_viewer="wslview" 
    " Mixture of
    " https://github.com/neovim/neovim/wiki/FAQ#how-to-use-the-windows-clipboard-from-wsl
    " and
    " https://stackoverflow.com/a/61864749
    " if wsl#is_wsl() && has('nvim')
    "     let $DISPLAY=trim(substitute(system("grep nameserver /etc/resolv.conf"), ".* ", "", "")) . ":0.0"
    "     echom "WSL Setup"
    "     let g:netrw_browsex_viewer="wslview" 
    " end
endfunction
