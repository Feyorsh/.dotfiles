call plug#begin('~/.local/share/nvim/plugged')

" Declare the list of plugins.
Plug 'neoclide/coc.nvim'
Plug 'tpope/vim-surround'
Plug 'chun-yang/auto-pairs'
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/fzf'
Plug 'pacha/vem-tabline'
Plug 'ryanoasis/vim-devicons'
Plug 'connorholyday/vim-snazzy'
Plug 'itchyny/lightline.vim'

" List ends here. Plugins become visible to Vim after this call.
" Run ":PlugInstall" to install.
call plug#end()

au VimEnter,VimResume * set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
  \,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
  \,sm:block-blinkwait175-blinkoff150-blinkon175

au VimLeave,VimSuspend * set guicursor=a:ver25-blinkon0

let g:SnazzyTransparent = 1

colorscheme snazzy
let g:lightline = { 'colorscheme': 'snazzy' }

set number
set relativenumber
set tabstop=4
set shiftwidth=4
set confirm
set noshowmode
syntax on
set mouse=a
set ttyfast
" set noswapfile
