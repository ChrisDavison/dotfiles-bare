set -Ux fish_greeting ""
set -Ux EDITOR "vim"
set -Ux VISUAL "vim"
set -Ux KNOWLEDGEDIR $HOME/notes
set -Ux BROWSER firefox

# Update PATH
# Do this first, so that I can check for binaries later
# e.g. only alias stuff if rust tools like exa or rg exist
fish_add_path -U $HOME/.bin
fish_add_path -U $HOME/.cargo/bin
fish_add_path -U $HOME/.local/bin
fish_add_path -U $HOME/.emacs.d/bin
fish_add_path -U $HOME/.npm-packages/bin
fish_add_path -U $HOME/.conda/bin
fish_add_path -U $HOME/.wasmtime/bin
fish_add_path -U $HOME/go/bin
fish_add_path -U $HOME/go/.bin
fish_add_path -U /usr/local/go/bin
fish_add_path -U /usr/local/julia/bin
fish_add_path -U /usr/local/zig
fish_add_path -U /usr/local/lib/nodejs/bin

for dir in (find $HOME/code/dotfiles/scripts -type d)
    set contents (ls $dir | rg 'py$|sh$' | wc -l)
    if test $contents -gt 0
        fish_add_path -U $dir
    end
end


set -Ux GOPATH "$HOME/go"
set -Ux WORKON_HOME "$HOME/.envs"
set -Ux LESS FRSX
set -Ux CODEDIR "$HOME/code/"
set -Ux VIRTUAL_ENV_DISABLE_PROMPT 0
set -Ux RUST_SRC_PATH "$HOME/.rust_src"
set -Ux RANGER_LOAD_DEFAULT_RC 0
set -Ux RE_UUID "[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}"
set -Ux AIRFLOW_HOME "$HOME/.config/airflow"
set -Ux BOOKMARKS_DIR "$HOME/bookmarks"
set -Ux CIDCOM_SERVERS skye uist jura iona mull bute cava

set -Ux TODOFILE "$HOME/notes/todo.txt"
set -Ux DONEFILE "$HOME/notes/done.txt"

set -Ux FZF_DEFAULT_COMMAND 'rg --files --no-ignore-vcs --hidden'
# if not test -z (which fd)
#     set -Ux FZF_DEFAULT_COMMAND 'fd --type file'
# else
# end

# color man
set -Ux LESS_TERMCAP_md (printf "\e[01;31m")
set -Ux LESS_TERMCAP_me (printf "\e[0m")
set -Ux LESS_TERMCAP_se (printf "\e[0m")
set -Ux LESS_TERMCAP_so (printf "\e[01;44;33m")
set -Ux LESS_TERMCAP_ue (printf "\e[0m")
set -Ux LESS_TERMCAP_us (printf "\e[01;32m")

set -Ux MANPAGER "less -R"

############################################################
alias b="bat --tabs 2 --color=always --style=numbers,changes "
alias bm="bookmarks"
alias clip="xclip -sel clipboard"
alias cp="cp -rv" # Always recursively and verbosely copy
alias df="df -x squashfs"
alias ipython="ipython --pprint --no-banner"
alias less='less -R' # Use color codes in 'less'
alias mkdir="mkdir -pv" # Always make parent directories, and explain what was done
alias mv="mv -v" # Always explain move actions
alias rg='rg -S' # Make ripgrep use smart-case by default
alias timestamp="date +'%F %H:%M:%S'"
alias today="date +%F"
alias ts="tagsearch"
alias l7w="last_work_week"
alias l7j="last_journal_week"
alias dls="cat ~/.download"
alias dlaq="dla -q"
alias tms="~/bin/tmux_sessionizer.sh"
alias tmux="tmux -2"
alias tma="tma.sh"
# alias t="todo.sh -d ~/.todo.txt.config"
alias tt="clear; and t"
alias nu="nasutil"

alias v="vim"

# some local vars for testing existance of tools
# if test -Ux "$HOME/.bin/nvim.appimage"
#     alias v="$HOME/.bin/nvim.appimage"
#     set -gx EDITOR "$HOME/.bin/nvim.appimage"
# end

alias g="git"
not test -z (which hub); and alias g="hub"

not test -z (which fdfind); and alias fd="fdfind"

if not test -z (which repoutil)
    alias ru="repoutil unclean"
    alias rs="repoutil stat"
    alias rl="repoutil list"
    alias rf="repoutil fetch"
    alias rb="repoutil branchstat | sed -e 's/.*code\///' | sort | column -s'|' -t"
else
    echo "repoutil not installed"
end

if not test -z (which exa)
    alias ls="exa --group-directories-first"
    alias l1="ls -1"
    alias lsa="exa --group-directories-first"
    alias ll="ls --long --group-directories-first"
    alias la="ll -a --group-directories-first"
    alias lt="exa --tree -L 2 --group-directories-first"
    alias lg="ll --git-ignore"
    alias ltg="lt --git-ignore"
else
    echo "exa not installed. install from cargo"
end

if not test -z (which ziputil)
    alias zc="ziputil choose"
    alias zv="ziputil view"
else
    echo "ziputil not installed"
end

if not test -z (which gh)
    gh completion -s fish | source
end


# Source python environment
test -f "$HOME/.envs/py/bin/activate.fish"; and source "$HOME/.envs/py/bin/activate.fish"

# Source starship for a more informative
# starship is a bit buggy within emacs (term, rather than vterm)
# so commenting out for now
# test -f "$HOME/.cargo/bin/starship"; and starship init fish | source
# test -f "/usr/local/bin/starship"; and starship init fish | source

# Ignore server login messages
not test -f "$HOME/.hushlogin"; and touch "$HOME/.hushlogin"

# WASM config
set -l WASMTIME_HOME "$HOME/.wasmtime"
string match -r ".wasmtime" "$PATH" >/dev/null; or set -Ux PATH "$WASMTIME_HOME/bin" $PATH

and zoxide init fish | source

# Setup only for WSL (linux on windows)
uname -r | grep -q -i 'microsoft'; and ~/code/dotfiles/scripts/wsl_interop.sh
