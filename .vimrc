filetype plugin indent on
syntax enable
let mapleader=" "

" Plugins {{{1
call plug#begin('~/.vim/plugins')

" Utility
Plug 'airblade/vim-rooter'           " Automatically cwd when in a project
Plug 'chrisdavison/vim-colourtoggle'  " Define and switch between light/dark themes
Plug 'chrisdavison/vim-datedfiles'   " Create files with some kind of date in name
Plug 'chrisdavison/vim-tagsearch'
Plug 'junegunn/fzf',              { 'dir': '~/.fzf', 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'justinmk/vim-dirvish'       " Better directory listing
Plug 'kana/vim-textobj-user'
Plug 'konfekt/fastfold'              " Smarter/faster updating of folds
Plug 'mg979/vim-visual-multi'
Plug 'troydm/zoomwintab.vim'  " <C-w>o to temporarily focus a buffer, like tmux <PREFIX>z
Plug 'tpope/vim-commentary'   " Easily comment ..stuff..
Plug 'tpope/vim-surround'     " 'Surround' text object
Plug 'tpope/vim-unimpaired'   " adds pairs of keybinds like ]b [b
Plug 'wellle/targets.vim'      
Plug 'neoclide/coc.nvim',         {'branch': 'release'}  " Completion
Plug 'tpope/vim-fugitive'     " Git in vim
" Plug 'SirVer/ultisnips'       " Snippet expander
Plug 'honza/vim-snippets'     " Snippets for various languages

" Navigation and code viewing
Plug 'romainl/vim-qf'
Plug 'christoomey/vim-tmux-navigator'  " Navigate across buffers & tmux panes
Plug 'dahu/vim-fanfingtastic'     " 'f' across newlines
Plug 'andymass/vim-matchup'       " Make % match more 'pairs' (e.g. IF ELSE ENDIF)
Plug 'ggandor/lightspeed.nvim'    " Press s<char1><char2> to easily navigate buffers

" Better writing experience
Plug 'chrisdavison/vim-checkmark', {'for': 'markdown'}  " Toggle checkboxes
Plug 'chrisdavison/vim-insertlink', {'for': 'markdown'} " Insert other file as markdown link
Plug 'dkarter/bullets.vim',         {'for': 'markdown'} " Continue lists automatically

" Language support
Plug 'vim-pandoc/vim-pandoc'
Plug 'vim-pandoc/vim-pandoc-syntax'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
" Install treesitter syntaxes with a maintainer, on a new system
" run `:TSInstall maintained`

" Themes
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'sainnhe/edge'

call plug#end()


" Plugin configuration
let g:knowledge_dir=expand("~/notes/")
let g:fzf_buffers_jump = 1
let g:fzf_preview_window=["right:50%:hidden", "ctrl-/"]
let g:fzf_layout={'window': {'width': 1.0, 'height': 0.3, 'relative': v:false, 'yoffset': 0.0}}
let g:datedfile_default_format="%Y-%m-%d-%A"
let g:datedfile_default_header_format="%Y-%m-%d %A"
let g:rustfmt_autosave=1
let g:markdown_filename_as_header_suppress=0

" settings {{{1
set cpo+=n
set number
set relativenumber
set wrap lbr
set autoindent
set breakindent
set breakindentopt=shift:4,sbr
set backspace=indent,eol,start
set iskeyword=a-z,A-Z,_,48-57  " Used e.g. when searching for tags
setglobal tags-=./tags tags-=./tags; tags^=./tags;
set incsearch
set updatetime=300 " Write a swap file after 1 second
set autoread
set tabstop=4 softtabstop=4 shiftround shiftwidth=4 expandtab
set clipboard+=unnamedplus " Use system clipboard with vim clipboard
set lazyredraw " Don't redraw while executing macros
set foldlevelstart=-1
" set autochdir
set cursorline
set guioptions-=m guioptions-=T
set noshowmode
set hlsearch
" set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
set listchars=tab:>-,trail:⋄
set cmdheight=2
set shortmess+=c  " No message for ins_completion
set shortmess+=I  " No intro message

set scrolloff=1
set sidescrolloff=5
set display+=lastline

" Some servers have issues with backup files
set nobackup nowritebackup
set history=1000
set tabpagemax=50
if !empty(&viminfo)
    set viminfo^=!
endif
set sessionoptions-=options
set viewoptions-=options

set directory=~/.vim/backups/,.
set ignorecase smartcase " ignore case unless i specifically mix letter case
set wildmenu
set wildmode=list:longest
set wildignore=*DS_Store*,*.png,*.jpg,*.gif,*.aux,*~,*tags$,*.swp,*.so,*.fls,*.log,*.out,*.toc,*.xdv,*.bbl,*.blg,*.fdb_latexmk,Thumbs.db
set wildignorecase
set nojoinspaces   " don't autoinsert two spaces after '.' etc in join
set switchbuf=useopen,usetab
set splitbelow splitright
set showmode
let g:netrw_hide=1

set smarttab
set nrformats-=octal
set formatoptions+=j  " Remove comment markers when joining lines
set formatoptions-=a  " Don't autoformat paragraphs
set signcolumn=yes
set path=.,**
set laststatus=2

set ruler
set encoding=utf-8

set undodir=~/.undodir
set undofile
set complete-=i
set completeopt=menuone,noinsert,noselect

set timeoutlen=300

if has('nvim')
    set inccommand=nosplit  " Live-preview of :s commands
endif

if executable('rg')
    set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case\ -g\ '!tags'
endif

let g:netrw_browsex_viewer="firefox --new-tab"

set omnifunc=v:lua.vim.lsp.omnifunc

set diffopt+=iwhite "no whitespace in vimdiff
set diffopt+=algorithm:patience
set diffopt+=indent-heuristic

" appearance {{{1
set t_ut= " Fix issues with background color on some terminals
set t_Co=16
if !has('gui_running')
    set t_Co=256
endif
if has('termguicolors') " Set true colours
    set termguicolors
endif

let g:dark_scheme='dracula'
let g:light_scheme='edge'
let g:colour_times=[7,20]  " Use light scheme between 7am and 8pm
call colourtoggle#dark()

" keybinds {{{1
nnoremap <silent> Q =ip

vnoremap <      <gv
vnoremap >      >gv
" Make j and k work, even on visually-wrapped (not hard-wrapped) lines
nnoremap <expr> j      (v:count == 0? 'gj' : 'j')
nnoremap <expr> k      (v:count == 0? 'gk' : 'k')
nnoremap D      dd
nnoremap Y      y$
" Easier rebind to go to the previously used buffer
nnoremap <BS>   <C-^>

" When jumping to a search pattern, center it in view
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *zz
nnoremap <silent> # #zz
nnoremap <silent> g* g*zz

" very magic search by default
nnoremap ? ?\v
nnoremap / /\v
cnoremap %s/ %sm/

" Use esc to go to normal mode in vim's inbuilt terminal
tnoremap <Esc> <C-\><C-n>

" Run 'equalprg' (format) and return to mark
nnoremap <leader>F :call myfuncs#format_and_return_to_mark()<CR>

" <C-C> doesn't trigger InsertLeave autocmd, so rebind to esc
inoremap <C-c> <ESC>

" Navigate to stuff in project (files, buffers, or tags)
nnoremap <leader>p :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>g :GFiles<cr>
nnoremap <leader>G :GFiles?<cr>
nnoremap <leader><leader> :Notes<CR>
nnoremap <leader>B :BLines<CR>

command! Notes :call fzf#vim#files(g:knowledge_dir, {'source': 'fd -e md'})

" Navigate to specific files
nnoremap <leader>ev :e ~/.vimrc<CR>

" NAS helpers
nnoremap <leader>ana :NASAdd<CR>
nnoremap <leader>anl :NASList<CR>

" Navigate :arglist
nnoremap <right> :next<CR>
nnoremap <left> :prev<CR>

nnoremap ]T :tabnext<cr>
nnoremap [T :tabprev<cr>

" coc.nvim
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gr <Plug>(coc-references)
nnoremap <silent> K :call <SID>show_documentation()<CR>
nnoremap <leader>o :CocList symbols<CR>
nnoremap <leader>i :CocList outline<CR>

" use <tab> for trigger completion and navigate to the next complete item
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <TAB>
      \ pumvisible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

" Use <C-l> for trigger snippet expand.
imap <C-l> <Plug>(coc-snippets-expand)

" Use <C-j> for select text for visual placeholder of snippet.
vmap <C-j> <Plug>(coc-snippets-select)

" Use <C-j> for jump to next placeholder, it's default of coc.nvim
let g:coc_snippet_next = '<c-j>'

" Use <C-k> for jump to previous placeholder, it's default of coc.nvim
let g:coc_snippet_prev = '<c-k>'

" Use <C-j> for both expand and jump (make expand higher priority.)
imap <C-j> <Plug>(coc-snippets-expand-jump)

" Use <leader>x for convert visual selected code to snippet
xmap <leader>x  <Plug>(coc-convert-snippet)

let g:coc_snippet_next = '<tab>'

xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

" Use tab to start snippets, c-j/k to navigate the $'s
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsListSnippers="<c-tab>"
let g:UltiSnipsJumpBackwardTrigger="<c-j>"
let g:UltiSnipsJumpForwardTrigger="<c-k>"
let g:UltiSnipsEditSplit="horizontal"

function! s:show_documentation()
    if(index(['vim', 'help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
    else
        call CocAction('doHover')
    endif
endfunction

let g:fzf_action = {
            \ 'ctrl-t': 'tab split',
            \ 'ctrl-x': 'split',
            \ 'ctrl-v': 'vsplit',
            \ 'ctrl-f': 'InsertFilename',
            \ 'ctrl-i': 'InsertLinkToNote',
            \ 'ctrl-l': 'InsertLinkToNoteBelow'}

command! -complete=file -nargs=1 InsertFilename call inserttext#AtPoint("`" . fnamemodify(<q-args>, ":~:.") . "`")

" abbreviations {{{1
cnoreabbrev <expr> grep  (getcmdtype() ==# ':' && getcmdline() =~# '^grep')  ? 'silent grep'  : 'grep'
cnoreabbrev <expr> greph  (getcmdtype() ==# ':' && getcmdline() =~# '^grep')  ? 'silent grep %<left><left>'  : 'grep %<left><left>'
cnoreabbrev <expr> lgrep (getcmdtype() ==# ':' && getcmdline() =~# '^lgrep') ? 'silent lgrep' : 'lgrep'
cnoreabbrev <expr> lgreph (getcmdtype() ==# ':' && getcmdline() =~# '^lgrep') ? 'silent lgrep %<left><left>' : 'lgrep %<left><left>'
cnoreabbrev W w
cnoreabbrev Wq wq
cnoreabbrev Qa qa
cnoreabbrev QA qa
cnoreabbrev E e
cnoreabbrev Q! q!
cnoreabbrev BD bp<bar>bd #
cnoreabbrev Bd bd
cnoreabbrev Set set
iabbrev <expr> DATE strftime("%Y-%m-%d")
iabbrev <expr> DATEB strftime("**%Y-%m-%d**")
iabbrev <expr> DATETIME strftime("`%Y-%m-%dT%H:%M`")
iabbrev <expr> TIME strftime("%H:%M:%S")
iabbrev <expr> TS strftime("**(%H:%M)**")
iabbrev <expr> DATEN strftime("%Y-%m-%d %A")

" commands & functions {{{1
command! RepoutilBranchstat :exec "!repoutil branchstat"
command! RepoutilFetch :exec "!repoutil fetch"
command! RepoutilList :exec "!repoutil list | sed -e 's/.*github.com.//'"
cnoreabbrev RF RepoutilFetch
cnoreabbrev RB RepoutilBranchstat
cnoreabbrev RL RepoutilList

command! ReadingTime exec "!readtime " . expand("%")

command! WordCount exec "!wc " . expand('%')
cnoreabbrev WC WordCount

command! -nargs=1 -complete=customlist,tagsearch#knowledge_projects Projects edit <q-args>

" ---------------------------
" Journal, Logbook, and Inbox
" ---------------------------
command! -nargs=* Journal call myfuncs#new_journal(<q-args>)

command! TodaysJournals call myfuncs#n_days_journals_fzf(1)
cnoreabbrev TJ TodaysJournals
nnoremap <leader>j :TodaysJournals<CR>

command! WeeksJournals call myfuncs#n_days_journals_fzf(7)
cnoreabbrev WJ WeeksJournals
nnoremap <leader>J :WeeksJournals<CR>

command! -nargs=+ Inbox call myfuncs#capture_inbox(<q-args>)

command! Logbook :call myfuncs#new_logbook()
command! Last7Logbooks call myfuncs#last_7_logbooks_in_vsplit()
command! Last7LogbooksQF call myfuncs#copen_last_7_logbooks()
command! -nargs=1 OtherLogbook call myfuncs#other_logbook(<q-args>)
cnoreabbrev LB Logbook
" -------------------------------
" add/list files on nas downloads
" -------------------------------
cnoreabbrev NASAdd !nasutil add
cnoreabbrev NASList !nasutil list
" ----------
" web search
" ----------
command! -nargs=+ DDG     call websearch#duckduckgo(<q-args>)
command! -nargs=+ YouTube call websearch#youtube(<q-args>)
command! -nargs=+ DevDocs call websearch#devdocs(<q-args>)
command! -nargs=+ CPP call websearch#cpp(<q-args>)
cnoreabbrev YT YouTube
" ---------------------
" search and navigation
" ---------------------
command! -nargs=+ GrepLogbook call grep#location(<q-args>, g:knowledge_dir . "logbook.md")
command! -nargs=+ GrepWork    call grep#location(<q-args>, g:knowledge_dir . "work.md")
command! -nargs=+ GrepNotes   call grep#location(<q-args>, g:knowledge_dir)
cnoreabbrev GN GrepNotes

command! -nargs=+ -complete=file JumpToHeading call markdown#jump_to_heading(<q-args>)

command! FileMarks marks ABCDEFGHIJKLMNOPQRSTUVWXYZ

" Change directory to the directory of the current file
command! CD cd %:h

if wsl#is_wsl()
    command! AHK :e /mnt/c/ahk/Keybinds.ahk
    call wsl#setup()
endif

function! s:edit_ftplugin() abort
    exec ":edit " . expand("~/.vim/after/ftplugin/" . &ft . ".vim")
endfunction

command! EditFTPlugin call <sid>edit_ftplugin()


" autocommands {{{1
augroup vimrc
    autocmd!
    au TextChanged,InsertLeave,FocusLost * silent! wall
    au CursorHold * silent! checktime " Check for external changes to files
    au VimResized * wincmd= " equally resize splits on window resize
    au BufWritePost .vimrc,init.vim nested source $MYVIMRC
    au BufWritePost * redraw

    au Filetype make setlocal noexpandtab
    au BufRead,BufNewFile *.latex setlocal filetype=tex

    au User CocJumpPlaceholder call CocActionSync('showSignatureHelp')

    " Zen writing
    au User GoyoEnter nested call goyo_util#limelight_on_and_tmux_off()
    au User GoyoLeave nested call goyo_util#limelight_off_and_tmux_on()

    " markdown
    au BufNewFile *.md call markdown#filename_as_header()
    au BufEnter *.md setlocal ft=markdown.pandoc
    au BufRead logbook*.md norm zCG

    " Goto last location in non-empty files
    au BufReadPost *  if line("'\"") > 1 && line("'\"") <= line("$")
                   \|     exe "normal! g`\""
                   \|  endif

    " When using treesitter, can get smarter folding
    au Filetype vim setlocal foldmethod=marker
    au Filetype go,rust,python,zsh,bash,sh
                \ setlocal foldmethod=expr
                \ foldexpr=nvim_treesitter#foldexpr()

    au BufWritePre *.go :call CocAction('runCommand', 'editor.action.organizeImport')

    au Filetype snippets setlocal formatoptions-=a 
    au Filetype python setlocal formatoptions-=a iskeyword=a-z,A-Z,_,48-57
    au Filetype python nnoremap <buffer> <leader>r :exec 'SlimeSend1 %run ' . expand('%:t')<CR>
    au Colorscheme * call myfuncs#set_codelens_colours()
augroup END

" TEMPORARY {{{1
command! -nargs=1 LargestNotes call myfuncs#large_notes_as_quickfix(<q-args>)<bar>:cw

nnoremap <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

