" Minimal Vim configuration (Vim 9.2+, not Neovim)
" Location: ~/.config/vim/vimrc (repo: ~/Workspace/vim)

scriptencoding utf-8

let mapleader = " "
let maplocalleader = " "

" ---------------------------------------------------------------------------
" Files, undo, swap
" ---------------------------------------------------------------------------
set nocompatible
set encoding=utf-8
set fileencoding=utf-8
set fileformats=unix,dos
set fileformat=unix
set history=1000
set hidden
set confirm
set autoread
set nobackup
set writebackup
set undofile
set undolevels=1000
set undoreload=10000

for s:dir in [
      \ expand('~/.local/state/vim/undo'),
      \ expand('~/.local/state/vim/swap'),
      \ expand('~/.local/state/vim/backup'),
      \ expand('~/.local/state/vim/fzf-history')]
  if !isdirectory(s:dir)
    call mkdir(s:dir, 'p')
  endif
endfor
unlet s:dir

let &undodir = expand('~/.local/state/vim/undo') . '//'
let &directory = expand('~/.local/state/vim/swap') . '//'
let &backupdir = expand('~/.local/state/vim/backup') . '//'
let &viminfofile = expand('~/.local/state/vim/viminfo')

" ---------------------------------------------------------------------------
" UI
" ---------------------------------------------------------------------------
set number
set relativenumber
set numberwidth=4
set cursorline
set colorcolumn=100
set textwidth=100
set scrolloff=8
set sidescrolloff=8
set signcolumn=yes
set nowrap
set laststatus=2
set noshowmode
set showcmd
set wildmenu
set wildmode=longest:full,full
set wildoptions=pum
set pumheight=12
set shortmess+=c
set splitright
set splitbelow
set nojoinspaces
set nrformats-=octal
set belloff=all
set noerrorbells
set visualbell
set t_vb=
set mouse=a
set backspace=indent,eol,start
set updatetime=300
set timeoutlen=500
set ttimeoutlen=10

let &statusline = '%{toupper(mode())}  %f%m%r%h%w%= %{&filetype}  %l:%c %P'
let &showbreak = '↪ '
let &fillchars = 'vert:│,fold:·,eob: '
let &listchars = 'tab:»\ ,trail:·,extends:›,precedes:‹,nbsp:␣'
set nolist

" ---------------------------------------------------------------------------
" Search and indentation
" ---------------------------------------------------------------------------
set ignorecase
set smartcase
set incsearch
set hlsearch
set wrapscan

set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set shiftround
set autoindent
set breakindent
set formatoptions-=cro

set completeopt=menuone,noinsert,noselect

filetype plugin indent on
syntax enable

" ---------------------------------------------------------------------------
" LSP (yegappan/lsp reads these globals when vim-plug loads it)
" ---------------------------------------------------------------------------
let g:lsp_options = {
      \ 'autoComplete': v:true,
      \ 'autoHighlightDiags': v:true,
      \ 'showInlayHints': v:true,
      \ 'showSignature': v:true,
      \ 'snippetSupport': v:false,
      \ 'hoverInPreview': v:false,
      \ 'showDiagWithVirtualText': v:false,
      \ 'showDiagOnStatusLine': v:false,
      \ 'completionMatcher': 'case',
      \ }

let g:lsp_servers = []

if executable('gopls')
  call add(g:lsp_servers, {
        \ 'name': 'gopls',
        \ 'filetype': ['go', 'gomod'],
        \ 'path': exepath('gopls'),
        \ 'args': ['serve'],
        \ 'syncInit': v:true,
        \ })
endif

if executable('rust-analyzer')
  call add(g:lsp_servers, {
        \ 'name': 'rust-analyzer',
        \ 'filetype': ['rust'],
        \ 'path': exepath('rust-analyzer'),
        \ 'args': [],
        \ 'syncInit': v:true,
        \ })
endif

if executable('lua-language-server')
  call add(g:lsp_servers, {
        \ 'name': 'lua-language-server',
        \ 'filetype': ['lua'],
        \ 'path': exepath('lua-language-server'),
        \ 'args': [],
        \ 'syncInit': v:true,
        \ })
endif

" ---------------------------------------------------------------------------
" fzf / netrw / grep
" ---------------------------------------------------------------------------
let g:fzf_layout = {'down': '~40%'}
let g:fzf_history_dir = expand('~/.local/state/vim/fzf-history')
let $FZF_DEFAULT_COMMAND = 'fd --type f --hidden --follow --exclude .git --exclude node_modules --exclude target --exclude dist --exclude .venv'

let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_winsize = 30
let g:netrw_browse_split = 0
let g:netrw_altv = 1
let g:netrw_chgwin = -1

let &grepprg = "rg --vimgrep --smart-case --hidden --glob '!.git'"
set grepformat=%f:%l:%c:%m

" ---------------------------------------------------------------------------
" Plugins
" ---------------------------------------------------------------------------
if filereadable(expand('~/.config/vim/autoload/plug.vim'))
  call plug#begin('~/.config/vim/plugged')

  Plug 'junegunn/fzf'
  Plug 'junegunn/fzf.vim'
  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-surround'
  Plug 'yegappan/lsp'
  Plug 'liuchengxu/vim-which-key'

  call plug#end()
endif

colorscheme habamax

" ---------------------------------------------------------------------------
" Mappings
" ---------------------------------------------------------------------------
nnoremap <silent> <C-s> :write<CR>
inoremap <silent> <C-s> <C-o>:write<CR>
xnoremap <silent> <C-s> <C-c>:write<CR>

inoremap jk <Esc>
nnoremap <silent> <Esc> :nohlsearch<CR><Esc>

nnoremap <silent> <C-h> <C-w>h
nnoremap <silent> <C-j> <C-w>j
nnoremap <silent> <C-k> <C-w>k
nnoremap <silent> <C-l> <C-w>l

nnoremap <silent> ]b :bnext<CR>
nnoremap <silent> [b :bprevious<CR>
nnoremap <silent> <leader>e :Lexplore!<CR>
nnoremap <silent> <leader>l :set list!<CR>

nnoremap <silent> <leader>f :Files<CR>
nnoremap <silent> <leader>b :Buffers<CR>
nnoremap <silent> <leader>/ :Rg<CR>
nnoremap <silent> <leader>j :Jumps<CR>

nnoremap <silent> <leader>c :Commentary<CR>
xnoremap <silent> <leader>c :Commentary<CR>

" ---------------------------------------------------------------------------
" which-key
" ---------------------------------------------------------------------------
function! s:which_key_setup() abort
  let g:which_key_map = {
        \ 'e': 'file explorer (right)',
        \ 'f': 'find files',
        \ 'b': 'buffers',
        \ '/': 'live grep',
        \ 'j': 'jumplist',
        \ 'l': 'toggle whitespace',
        \ 'c': 'commentary',
        \ 'F': 'format buffer',
        \ }

  let g:which_key_position = 'botright'
  let g:which_key_hspace = 2

  call which_key#register('<Space>', 'g:which_key_map')
  nnoremap <silent> <leader> :<C-u>WhichKey '<Space>'<CR>
  xnoremap <silent> <leader> :<C-u>WhichKeyVisual '<Space>'<CR>
endfunction

augroup vimrc_which_key
  autocmd!
  autocmd VimEnter * if exists(':WhichKey') == 2 | call s:which_key_setup() | endif
augroup END

" ---------------------------------------------------------------------------
" Formatting
" ---------------------------------------------------------------------------
let s:lsp_fts = ['go', 'gomod', 'rust', 'lua']
let s:prettier_fts = [
      \ 'javascript', 'javascriptreact',
      \ 'typescript', 'typescriptreact',
      \ 'json', 'jsonc', 'css', 'scss', 'less', 'html',
      \ 'markdown', 'yaml']

function! s:prettier() abort
  if !executable('prettier') || empty(expand('%')) || line('$') > 5000
    return 0
  endif

  let l:input = join(getline(1, '$'), "\n")
  let l:out = systemlist(
        \ 'prettier --stdin-filepath ' . shellescape(expand('%:p')), l:input)

  if v:shell_error != 0 || empty(l:out)
    return 0
  endif

  let l:view = winsaveview()
  silent keepjumps %delete _
  call setline(1, l:out)
  call winrestview(l:view)
  return 1
endfunction

function! s:format(verbose) abort
  if &binary || !&modifiable
    return 0
  endif

  if index(s:lsp_fts, &filetype) >= 0
    if exists('*LspServerReady') && LspServerReady()
      silent! LspFormat
      return 1
    endif
    if a:verbose
      echohl WarningMsg | echomsg 'LSP server not ready for ' . &filetype | echohl None
    endif
    return 0
  endif

  if index(s:prettier_fts, &filetype) >= 0
    let l:ok = s:prettier()
    if !l:ok && a:verbose
      echohl WarningMsg | echomsg 'prettier failed for ' . &filetype | echohl None
    endif
    return l:ok
  endif

  if a:verbose
    echohl WarningMsg | echomsg 'No formatter configured for ' . &filetype | echohl None
  endif
  return 0
endfunction

function! s:autoformat() abort
  if !&modified || &binary || !&modifiable
    return
  endif

  if index(s:lsp_fts, &filetype) >= 0
    if exists('*LspServerReady') && LspServerReady()
      silent! LspFormat
    endif
    return
  endif

  if index(s:prettier_fts, &filetype) >= 0
    call s:prettier()
  endif
endfunction

function! s:trim_trailing_whitespace() abort
  if &binary || !&modifiable
    return
  endif
  let l:view = winsaveview()
  silent! keeppatterns %s/\s\+$//e
  call winrestview(l:view)
endfunction

function! s:restore_cursor() abort
  if line("'\"") > 1 && line("'\"") <= line('$')
    execute 'normal! g`"'
  endif
endfunction

command! Format call s:format(1)
nnoremap <silent> <leader>F :Format<CR>

" ---------------------------------------------------------------------------
" Autocommands
" ---------------------------------------------------------------------------
augroup vimrc_fileops
  autocmd!
  autocmd BufWritePre * call s:autoformat()
  autocmd BufWritePre * call s:trim_trailing_whitespace()
  autocmd BufReadPost * call s:restore_cursor()
  autocmd FocusGained,BufEnter * if mode() ==# 'n' && !&modified | checktime | endif
augroup END

augroup vimrc_formatoptions
  autocmd!
  autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
augroup END

augroup vimrc_terminal
  autocmd!
  autocmd TerminalOpen * setlocal nonumber norelativenumber signcolumn=no
augroup END

tnoremap <Esc> <C-\><C-n>

" ---------------------------------------------------------------------------
" Buffer-local LSP mappings
" ---------------------------------------------------------------------------
function! s:lsp_maps() abort
  nnoremap <buffer> <silent> gd :LspGotoDefinition<CR>
  nnoremap <buffer> <silent> gD :LspGotoDeclaration<CR>
  nnoremap <buffer> <silent> gr :LspShowReferences<CR>
  nnoremap <buffer> <silent> gi :LspGotoImpl<CR>
  nnoremap <buffer> <silent> gy :LspGotoTypeDef<CR>
  nnoremap <buffer> <silent> K :LspHover<CR>
  nnoremap <buffer> <silent> <leader>s :LspDocumentSymbol<CR>
  nnoremap <buffer> <silent> <leader>S :LspSymbolSearch<CR>
  nnoremap <buffer> <silent> <leader>d :LspDiagShow<CR>
  nnoremap <buffer> <silent> <leader>a :LspCodeAction<CR>
  nnoremap <buffer> <silent> <leader>r :LspRename<CR>
  nnoremap <buffer> <silent> <leader>h :LspHover<CR>
  nnoremap <buffer> <silent> ]d :LspDiagNext<CR>
  nnoremap <buffer> <silent> [d :LspDiagPrev<CR>
endfunction

augroup vimrc_lsp
  autocmd!
  autocmd FileType go,gomod,rust,lua call s:lsp_maps()
augroup END
