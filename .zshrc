DOTFILES=$HOME/code/dotfiles

###########
## checks #
###########
export IS_WSL=0
if [[ -n $(uname -a | grep -i microsoft) ]]; then
    export IS_WSL=1
fi

if [[ -x "$HOME/.bin/nvim.appimage" ]]; then
    HAS_NVIM_APPIMAGE=1
fi

############
## exports #
############

export EDITOR="nvim"
export VISUAL="nvim"
if [[ "$HAS_NVIM_APPIMAGE" -eq 1 ]]; then
    export EDITOR="$HOME/.bin/nvim.appimage"
    export VISUAL="$HOME/.bin/nvim.appimage"
fi
export BOOKMARKS_DIR="$HOME/bookmarks"
export BROWSER="firefox"
export CIDCOM_SERVERS=( skye uist jura iona mull bute cava )
export CODEDIR="$HOME/code"
export CCL_DEFAULT_DIRECTORY="$HOME/code/z-external/ccl-dev"
export FZF_DEFAULT_COMMAND='rg --files -S --no-ignore --hidden --follow --glob "!.git/*"'
export GOBIN="$HOME/.bin"
export GOPATH="$HOME"
export KNOWLEDGEDIR="$HOME/notes"
export LC_ALL=en_GB.UTF-8
export LESS=FRSX
export MAIL=$HOME/.mbox
export PATH="$WASMTIME_HOME/bin:$PATH"
export RANGER_LOAD_DEFAULT_RC=0
export RE_UUID="[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}"
export RUST_SRC_PATH=$(rustc --print sysroot)/lib/rustlib/src/rust/library
export VIRTUAL_ENV_DISABLE_PROMPT=0
export WASMTIME_HOME="$HOME/.wasmtime"
export WORKON_HOME="$HOME/.envs"

#########
## path #
#########
export PATH="$HOME/bin":$PATH
export PATH="$HOME/.bin":$PATH
export PATH="$HOME/.fzf/bin":$PATH
export PATH="$HOME/.cargo/bin":$PATH
export PATH="$HOME/go/bin":$PATH
export PATH="$HOME/.local/bin":$PATH
export PATH="$HOME/.local/go/bin":$PATH
export PATH="$HOME/.anaconda3/bin":$PATH
export PATH="$HOME/.wasmtime/bin":$PATH
export PATH="$HOME/.npm-packages/bin":$PATH
export PATH="/usr/local/go/bin":$PATH
export PATH="/usr/share/node/bin":$PATH
export PATH="/usr/share/node/bin":$PATH

scriptdir="$DOTFILES/scripts"
scriptdir="$HOME/code/scripts"
export PATH="$scriptdir":$PATH
for dir in $(find $scriptdir -type d | grep -v '\.git'); do
    export PATH="$dir":$PATH
done

# remove duplicates from path
typeset -U path
typeset -U PATH

export MANPAGER="less -R"


###########
## setopt #
###########

HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=$HISTSIZE

setopt append_history # multiple shells can append to history
setopt hist_ignore_dups # remove older duplicate entries from history
setopt hist_ignore_all_dups # remove older duplicate entries from history
setopt hist_reduce_blanks # remove superfluous blanks from history items
setopt inc_append_history # save history entries as soon as they are entered
setopt share_history # share history between different instances of the shell

setopt auto_cd # cd by typing directory name if it's not a command
setopt cdablevars # cd by typing a variable, if variable is a directory
setopt auto_pushd # cd pushes directories onto the stack
setopt pushd_ignore_dups # don't push multiple copies of same dir onto stack

setopt auto_list # automatically list choices on ambiguous completion
setopt auto_menu # automatically use menu completion
setopt always_to_end # move cursor to end if word had one match

setopt no_beep #turn off terminal bell
setopt extended_glob
setopt interactive_comments # Allow comments in interactive shells

set -o emacs



###############
## completion #
###############

zstyle ':completion:*' menu select # select completions with arrow keys
zstyle ':completion:*' group-name '' # group results by category
zstyle ':completion:::::' completer _expand _complete _ignored _approximate #enable approximate matches for completion

autoload -Uz compinit; compinit -i
autoload zmv



#############
## keybinds #
#############

# keybinds
# up and down do history search
bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward



############
## aliases #
############
alias b="bat --tabs 2 --color=always --style=numbers,changes "
alias bm="bookmarks"
alias clip="xclip -sel clipboard"
alias cp="cp -rv"    # Always recursively and verbosely copy
alias df="df -x squashfs"
alias g="git"
alias inbox="nvim $HOME/code/knowledge/inbox.txt"
alias ipython="ipython --pprint --no-banner"
alias less='less -R'    # Use color codes in 'less'
alias mkdir="mkdir -pv"   # Always make parent directories, and explain what was done
alias mv="mv -v"     # Always explain move actions
alias rg='rg -S'   # Make ripgrep use smart-case by default
alias rgl="rg --multiline --multiline-dotall"
alias sz="source ~/.zshrc"
alias timestamp="date +'%F %H:%M:%S'"
alias tmux="TERM=xterm-256color tmux -2"
alias today="date +%F"
alias ts="tagsearch"
alias v=$EDITOR
alias nu="nasutil"
alias mux="tmuxinator"

# aliases (conditional)
 
alias ru="repoutil unclean"
alias rs="repoutil stat"
alias rl="repoutil list"
alias rf="repoutil fetch"
alias rb="repoutil branchstat | sed -e 's/.*code\///' | sort | column -s'|' -t"

if [[ -x "$HOME/.cargo/bin/exa" ]]; then
    default_exa="exa --group-directories-first"
    alias ls="$default_exa"
    alias ll="$default_exa --long --git"
    alias la="$default_exa --long -a --git"
    alias lt="$default_exa --tree"
else
    echo "Exa not installed"
    alias ls="ls --color --group-directories-first"
    alias ll="ls -l"
    alias la="ls -l -a"
fi

##############
## functions #
##############

tsf() {
    ts $(ts --long | fzf -m)
}

inpath() { # Check ifa file is in $PATH
    type "$1" >/dev/null 2>&1;
}

nonascii() { # Ripgrep for non-ascii, greek, or "£"
    rg "[^\x00-\x7F£\p{Greek}]" -o --no-heading
}

refresh_dmenu() {
    [ -f ~/.cache/dmenu_run ] && rm ~/.cache/dmenu_run && dmenu_path
}

git_aliases (){
    git config --list | rg alias | column -s '=' -t | sort
}

is_in_git_repo() { 
  git rev-parse HEAD > /dev/null 2>&1
} 

monospace-fonts(){ 
    fc-list :mono | cut -d':' -f2  | cut -d',' -f1 | sort | uniq
} 

duplicates(){ # find duplicate words in a file 
    [[ $# -eq 0 ]] && echo "usage: duplicates <file>..." && return
    grep -Eo '(\b.+) \1\b' $1 || true
} 

due() {
    nlt.py -f "due:%Y-%m-%d" $@
}

tma() {
    if [ ! -z "$TMUX" ]; then
        echo "ALREADY IN TMUX"
        return
    fi
    chosen=`tmux ls | cut -d':' -f1 | fzf -0 -1`
    if [ ! -z "$chosen" ]; then
        tmux attach -t "$chosen"
    else
        tmux
    fi
}


fzgm() {
    git ls-files -o -m --exclude-standard | fzf -m -0 -1
}

winhome(){
    echo "/mnt/c/Users/davison/"$1
}

last_work_week(){
    last7days.py ~/code/logbook/`date +%Y` | bat -l md
}
alias l7w="last_work_week"

last_journal_week(){
    last7days.py ~/code/knowledge/journal | bat -l md
}
alias l7j="last_journal_week"

free_space_on() {
    echo $1
    ssh $1 "df -H | grep '/\$\|media'"
}

run_on_cidcom_servers() {
    command=$@
    for server in $CIDCOM_SERVERS; do
        echo $server
        ssh $server $command
        echo "----------------------------------------"
    done
}

sanitise() {
    num=$#
    if [[ $num -eq 0 ]]; then
        echo "usage: sanitise <filename>"
        return
    fi
    echo $(basename "$@") | tr '[:upper:]' '[:lower:]' | sed 's/[^a-zA-Z0-9.-
           │ ]/-/g'  | tr -s - - | sed 's/\-$//g'
           
}

lowercase() {
    echo $@ | tr '[:upper:]' '[:lower:]'
}

uppercase() {
    echo $@ | tr '[:lower:]' '[:upper:]' 
}

strlen() {
    echo ${#1}
}

strrepeat() {
    if [[ $# -ne 2 ]]; then
        echo "usage: strrepeat STRING N"
        return
    fi
    printf "$1%.0s" {1..$2}
}

strjoin() {
    local IFS="$1"
    shift
    echo "$*"
}

strsplit() {
    div=$1
    shift
    echo $@ | tr $div "\n"
}

# CD to something relative to $HOME
cdh() {
    pushd $HOME 2>&1 > /dev/null
    if [[ -x $(which fd) ]]; then
        chosen=$(fd . -L --max-depth 4 --type d | fzf -0)
    else
        chosen=$(find -maxdepth 4 -type d | fzf -0)
    fi
    if [[ -z "$chosen" ]]; then
        return
    fi
    pushd $HOME/$chosen 2>&1 > /dev/null
}
bindkey -s '^[C' 'cdh\n'

# Git dirs near $HOME
cdg() {
    pushd $HOME 2>&1 > /dev/null
    chosen=$(fd -t d '.git$' -H --max-depth 4 | sed 's_/.git__g' | rg -v '^\.' | fzf)
    if [[ -z $chosen ]]; then
        return
    fi
    pushd $chosen 2>&1 > /dev/null
}
bindkey -s '^[G' 'cdg\n'

# Change to unclean repos
cdu() {
    chosen=$(repoutil unclean | fzf)
    if [[ -z $chosen ]]; then
        return
    fi
    pushd $chosen 2>&1 > /dev/null

}
bindkey -s '^[U' 'cdu\n'

newerthan() {
    date="$1"
    if [[ -x $(which fd) ]]; then
        fd --change-newer-than "$date"
    else
        find . -newermt "$date"
    fi
}


newerthanrelative() {
    newerthan $(date -d "$1" +%F)
}

# mystr="hOw Do I dO cOoL sTrInG sTuFf In ZsH?"

# TODO string replace
# TODO string sub

# string trim
# # using awk
# strtrim="\t\t   \t   \t text   \t\t\t  \t"
# echo $strtrim | awk '{$1=$1};1'

# string unescape


###########
## prompt #
###########

#!/usr/bin/env sh

# Prompt symbol
COMMON_PROMPT_SYMBOL="❯"

# Colors
COMMON_COLORS_HOST_ME=green
COMMON_COLORS_HOST_AWS_VAULT=yellow
COMMON_COLORS_CURRENT_DIR=blue
COMMON_COLORS_RETURN_STATUS_TRUE=yellow
COMMON_COLORS_RETURN_STATUS_FALSE=red
COMMON_COLORS_GIT_STATUS_DEFAULT=green
COMMON_COLORS_GIT_STATUS_STAGED=red
COMMON_COLORS_GIT_STATUS_UNSTAGED=yellow
COMMON_COLORS_GIT_PROMPT_SHA=green
COMMON_COLORS_BG_JOBS=yellow


# Prompt with current SHA
# PROMPT='$(common_host)$(common_current_dir)$(common_bg_jobs)$(common_return_status)'
# RPROMPT='$(common_git_status) $(git_prompt_short_sha)'

# Host
common_host() {
  if [[ -n $SSH_CONNECTION ]]; then
    me="%n@%m"
  elif [[ $LOGNAME != $USER ]]; then
    me="%n"
  fi
  if [[ -n $me ]]; then
    echo "%{$fg[$COMMON_COLORS_HOST_ME]%}$me%{$reset_color%}:"
  fi
  if [[ $AWS_VAULT ]]; then
    echo "%{$fg[$COMMON_COLORS_HOST_AWS_VAULT]%}$AWS_VAULT%{$reset_color%} "
  fi
}

# Current directory
common_current_dir() {
  echo -n "%{$fg[$COMMON_COLORS_CURRENT_DIR]%}%c "
}

# Prompt symbol
common_return_status() {
  echo -n "%(?.%F{$COMMON_COLORS_RETURN_STATUS_TRUE}.%F{$COMMON_COLORS_RETURN_STATUS_FALSE})$COMMON_PROMPT_SYMBOL%f "
}

# Git status
common_git_status() {
    local message=""
    local message_color="%F{$COMMON_COLORS_GIT_STATUS_DEFAULT}"

    # https://git-scm.com/docs/git-status#_short_format
    local staged=$(git status --porcelain 2>/dev/null | grep -e "^[MADRCU]")
    local unstaged=$(git status --porcelain 2>/dev/null | grep -e "^[MADRCU? ][MADRCU?]")

    if [[ -n ${staged} ]]; then
        message_color="%F{$COMMON_COLORS_GIT_STATUS_STAGED}"
    elif [[ -n ${unstaged} ]]; then
        message_color="%F{$COMMON_COLORS_GIT_STATUS_UNSTAGED}"
    fi

    local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [[ -n ${branch} ]]; then
        message+="${message_color}${branch}%f"
    fi

    echo -n "${message}"
}

# Git prompt SHA
ZSH_THEME_GIT_PROMPT_SHA_BEFORE="%{%F{$COMMON_COLORS_GIT_PROMPT_SHA}%}"
ZSH_THEME_GIT_PROMPT_SHA_AFTER="%{$reset_color%} "

# Background Jobs
common_bg_jobs() {
  bg_status="%{$fg[$COMMON_COLORS_BG_JOBS]%}%(1j.↓%j .)"
  echo -n $bg_status
}

fancy_prompt() {
    p_at='%(!.%F{red}%B#%b%f.@)'
    p_host='%F{yellow}%m%f'
    p_path='%F{yellow}%~%f'
    p_pr='%(?.%F{yellow}.%F{red})>%f'

    PS1="$p_at$p_host $p_path$p_pr "
    unset p_at p_host p_path p_pr

    # Left Prompt
    # PROMPT="$(common_host)$(common_current_dir)$(common_bg_jobs)$(common_return_status)"

    # Right Prompt
    RPROMPT=""
}


source $DOTFILES/prompt.zsh && fancy_prompt

[[ "$IS_WSL" -eq 1 ]] && source $DOTFILES/wsl.sh

# Other programs
[[ -f $HOME/.envs/py/bin/activate ]] && source $HOME/.envs/py/bin/activate
[[ -f $HOME/.cargo/env ]] && source $HOME/.cargo/env
[[ -f $HOME/.fzf/shell/key-bindings.zsh ]] && source $HOME/.fzf/shell/key-bindings.zsh
[[ -f $HOME/.fzf.zsh ]] && source $HOME/.fzf.zsh

# Hide server welcome messages
[[ ! -f "$HOME/.hushlogin" ]] && touch "$HOME/.hushlogin"

[[ -x $(which zoxide) ]] && eval "$(zoxide init zsh)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source $DOTFILES/scripts/antigen.zsh

antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle colored-man-pages
antigen apply

# if [[ -z "$TMUX" ]]; then
#     tmux attach -t notes || tmux new -s notes
# fi

export PATH="$HOME/.poetry/bin:$PATH"
