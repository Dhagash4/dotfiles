""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VimTeX
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:vimtex_doc_handlers = ['vimtex#doc#handlers#texdoc']
let g:vimtex_imaps_enabled = 0
let g:vimtex_toc_config = { 'layers' : ['content'], 'show_help' : 0}
let g:vimtex_quickfix_open_on_warning = 1
let g:vimtex_quickfix_method = 'pplatex'
let g:vimtex_quickfix_ignore_filters = [
      \ 'Underfull \\vbox',
      \ 'Overfull \\vbox',
      \ 'Underfull \\hbox',
      \ 'Package hyperref',
      \ 'Overfull \\hbox',
      \ 'LaTeX Font',
      \ 'Float too large',
      \ 'contains only floats',
      \ 'Package caption',
      \ 'multiple pdfs with page group included in a single page',
      \]

let g:vimtex_complete_close_braces = 1
let g:vimtex_complete_ref = {
  \ 'custom_patterns': [
  \  '\\figref\*\?{[^}]*$',
  \  '\\secref\*\?{[^}]*$',
  \  '\\tabref\*\?{[^}]*$',
  \  '\\eqref\*\?{[^}]*$',
  \  '\\algref\*\?{[^}]*$',
  \  '\\partref\*\?{[^}]*$',
  \  '\\chapref\*\?{[^}]*$',
  \  ]
  \ }

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Viewer for Linux/macOS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has("macunix")
  let g:vimtex_view_method = 'skim'
  " Backward search from pdf->vim in macOS
  function! s:TexFocusVim() abort
    silent execute "!open -a kitty"
    redraw!
  endfunction

  augroup vimtex_event_focus
    au!
    au User VimtexEventViewReverse call s:TexFocusVim()
  augroup END
elseif has("unix")
  let g:vimtex_view_method = 'zathura'
endif
