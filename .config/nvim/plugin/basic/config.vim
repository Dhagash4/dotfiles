" --- Set Leader Key to space
let mapleader = " "

" --- Enable filetype indent
filetype plugin indent on

" --- VIM RELATED SETTINGS
set number relativenumber
set splitright

" --- AIRLINE THEME ---
let g:airline_theme = 'gruvbox_material'
let g:airline_left_sep = ''
let g:airline_powerline_fonts=1

" --- THEME ---
set background=dark
let g:gruvbox_material_background = 'dark'
let g:gruvbox_material_better_performance = 1
let g:gruvbox_italicize_comments = 1
let g:gruvbox_italicize_strings = 1

colorscheme gruvbox

"--- Text, tab and indent related
set smarttab
set autoindent
set smartindent
set wrap
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=-1

" Python path for nvim
let g:python3_host_prog = "/Users/dhagash/anaconda3/bin/python3"

"Binding for gotodefination
nmap <silent>gd <C-]>

" --- FOR BETTER LIFE ---
nnoremap <Up> <NOP>
nnoremap <Down> <NOP>
nnoremap <Left> <NOP>
nnoremap <Right> <NOP>
"---- TAB SWITCH ----------------
nnoremap <C-Left> :tabprevious<CR>
nnoremap <C-Right> :tabnext<CR>
