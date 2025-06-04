" --- CoC Config ---
let g:coc_snippet_next = '<tab>'
let g:coc_snippet_prev = '<S-tab>'
let g:coc_config_home='$HOME/.config/nvim/plugin/coc'
let g:coc_global_extensions = [
      \'coc-clangd',
      \'coc-git',
      \'coc-docker',
      \'coc-cmake',
      \'coc-emoji',
      \'coc-explorer',
      \'coc-json',
      \'coc-lua',
      \'coc-markdownlint',
      \'coc-pyright',
      \'coc-python',
      \'coc-snippets',
      \'coc-vimlsp',
      \'coc-vimtex',
      \'coc-word',
      \'coc-yaml',
      \'coc-tsserver',
      \'coc-eslint',
      \'coc-prettier',
      \'coc-html',
      \'coc-css',
      \'coc-styled-components',
      \'coc-tailwindcss'
      \]


" Use tab for trigger completion with characters ahead and navigate.
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
" inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
"                               \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() 
      \: "\<C-g>u\<CR>\<C-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
      let col = col('.') - 1
      return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Enable Ctags search
" set tagfunc=CocTagFunc

"--- CoC code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> ff <Plug>(coc-fix-current)
