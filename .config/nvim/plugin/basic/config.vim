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
set nohlsearch
set clipboard+=unnamedplus

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

" Always move down with vim keys even in soft-lines
noremap < expr> j v:count ? 'j' : 'gj'
noremap <expr> k v:count ? 'k' : 'gk'

" Toggle highlight when <leader><cr> is pressed
map <silent><expr> <leader><cr> (&hls && v:hlsearch ? ':set nohlsearch' : ':set hls')."\n"

" Copy paste: leader+c / leader+v
map <silent><C-c> "+y
map <silent><C-p> "0p

""""""""""""""""""""""""""""""""""""""""""
"Fold
""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""
set foldmethod=expr
set foldexpr=v:lua.vim.treesitter.foldexpr()
set nofoldenable
set foldlevel=99
set foldtext=""
set foldlevelstart=1
set foldnestmax=4

""""""""""""""""""""""""""""""""""""""""""
"Zenmode
""""""""""""""""""""""""""""""""""""""""""
nnoremap <leader>z :ZenMode<CR>

""""""""""""""""""""""""""""""""""""""""""
"Saving made easy
""""""""""""""""""""""""""""""""""""""""""
map <silent><C-s>     :w<cr>
map! <silent><C-s>     <ESC>:w<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Format Settings (using Neoformat)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:neoformat_enabled_cpp = ['clangformat']
let g:neoformat_enabled_python = ['black', 'docformatter', 'isort']
let g:neoformat_only_msg_on_error = 0
let g:neoformat_run_all_formatters = 0
let g:shfmt_opt="-ci"

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Neoformat
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <leader>F :Neoformat<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Telescope
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <silent> <leader>ff :Telescope find_files<CR>
nnoremap <silent> <leader>fg :Telescope live_grep<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Fzf (alt-Q to build_quickfix_list) [https://github.com/junegunn/fzf.vim/issues/185]
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" An action can be a reference to a function that processes selected lines
function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val, "lnum": 1 }'))
  copen
  cc
endfunction

let g:fzf_action = {
      \ 'alt-q': function('s:build_quickfix_list'),
      \ 'ctrl-t': 'tab split',
      \ 'ctrl-x': 'split',
      \ 'ctrl-v': 'vsplit' }

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Quickfix list modifications
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <leader>cn :cnext<CR>
nnoremap <leader>cp :cprev<CR>
nnoremap <leader>co :copen<CR>
nnoremap <leader>cc :cclose<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => TagAlong modifications
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:tagalong_additional_filetypes = ['javascript']
