" Vim-Plug: A Vim plugin manager
call plug#begin('~/.config/nvim/plugged')

" Plugins
" Emmet for HTML/CSS abbreviation expansion
Plug 'mattn/emmet-vim'

" NERDTree for file system navigation
Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }

" Nightfox: A dark color scheme
Plug 'EdenEast/nightfox.nvim'

call plug#end()

" Note: Run :PlugInstall after modifying this file to install new plugins.
