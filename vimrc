" no vi compatibility
set nocompatible

" pathogen for plugin managment
call pathogen#runtime_append_all_bundles()
filetype plugin indent on

set number
set nocompatible
set nocompatible
set modelines=0
set tabstop=4
set shiftwidth=4
set softtabstop=4
set encoding=utf-8
set scrolloff=3
set autoindent
set showmode
set showcmd
set hidden
set wildmenu
set wildmode=list:longest
set visualbell

set ttyfast
set ruler
set backspace=indent,eol,start
set laststatus=2

set ignorecase
set smartcase
set gdefault
set incsearch
set showmatch
set hlsearch

nnoremap / /\v
vnoremap / /\v

set wrap
set textwidth=79
set formatoptions=qrn1
set colorcolumn=79

set list "show invisibles
set listchars=tab:▸\ ,eol:¬

set nobackup
set nofoldenable " Fuck code folding...

" map Shift-U to REDO
" map <S-u> <C-r>

nnoremap j gj
nnoremap k gk
nnoremap ; :


let mapleader = ","
nnoremap <leader>W :%s/\s\+$//<cr>:let @/=''<CR>
nnoremap <leader>a :Ack
nnoremap <leader>q gqip
nnoremap <leader>ev <C-w><C-v><C-l>:e $MYVIMRC<cr>

inoremap jj <ESC>

" Replicate textmate CMD-[ and CMD-] for indentation
nmap <D-[> <<
nmap <D-]> >>
vmap <D-[> <gv
vmap <D-]> >gv

" comments
imap <D-/> gcc
nmap <D-/> gcc
vmap <D-/> gcgv

" Toggle show invisibles
nmap <leader>i :set list!<CR>

" Use the below highlight group when displaying bad whitespace is desired.
highlight BadWhitespace ctermbg=red guibg=red

" Make trailing whitespace be flagged as bad.
au BufRead,BufNewFile *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/

" For full syntax highlighting:
# let python_highlight_all=1

"set iskeyword+=.

autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS

set mouse=a

set guifont=Inconsolata:h13
color molokai

map <D-Space> <Esc><Space>

if has("gui_macvim")
    let macvim_hig_shift_movement = 1
    set guioptions-=T
endif

