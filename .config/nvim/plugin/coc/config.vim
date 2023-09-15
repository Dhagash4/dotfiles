" --- CoC Config ---
let g:coc_config_home='$HOME/.config/nvim/plugin/coc'
let g:coc_global_extensions = [
      \'coc-clangd',
      \'coc-cmake',
      \'coc-emoji',
      \'coc-explorer',
      \'coc-json',
      \'coc-lua',
      \'coc-markdownlint',
      \'coc-pyright',
      \'coc-snippets',
      \'coc-vimlsp',
      \'coc-vimtex',
      \'coc-word',
      \'coc-yaml',
      \]


" use <tab> to trigger completion and navigate to the next complete item
" <tab> could be remapped by another plugin, use :verbose imap <tab> to check if it's mapped as expected.
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
inoremap <silent><expr> <Tab>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(4) : "\<C-h>"


" --- CoC Autocompletion using TAB
function! CheckBackSpace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackSpace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" --- CoC code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> ff <Plug>(coc-fix-current)
