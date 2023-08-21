"--Plugins for vim
call plug#begin()

"Insert, delete, quotes, brackets in pair
Plug 'jiangmiao/auto-pairs'

" Changing surroundings easy
Plug 'tpope/vim-surround'

" Comments Uncomment
Plug 'tpope/vim-commentary'

" Syntax highlighting 
Plug 'sheerun/vim-polyglot'

"CoC
Plug 'neoclide/coc.nvim', {'branch': 'release'}

"GruvBox Theme
Plug 'morhetz/gruvbox'

"GruvBox Material Theme
Plug 'sainnhe/gruvbox-material'

"Status like theme
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

"PyDocstring
Plug 'heavenshell/vim-pydocstring', { 'do': 'make install', 'for': 'python' }

" NERD Tree
Plug 'preservim/nerdtree' | Plug 'Xuyuanp/nerdtree-git-plugin' | Plug 'ryanoasis/vim-devicons'

" Fuzzy finder
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.1' }
Plug 'BurntSushi/ripgrep'
Plug 'sharkdp/fd'
Plug 'nvim-treesitter/nvim-treesitter'

" To have infinite undo
Plug 'simnalamburt/vim-mundo'

" Developers icons
Plug 'ryanoasis/vim-devicons'

" Move consistently between windows in tmux and vim
Plug 'christoomey/vim-tmux-navigator'

" Latex extension
Plug 'lervag/vimtex'

" Track the engine.
Plug 'SirVer/ultisnips'

" Snippets are separated from the engine. Add this if you want them:
Plug 'honza/vim-snippets'

call plug#end()
