call plug#begin('~/.local/share/nvim/plugged')

" Declare the list of plugins.
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'tpope/vim-surround'
Plug 'chun-yang/auto-pairs'
Plug 'scrooloose/nerdtree'
Plug 'junegunn/fzf'

" List ends here. Plugins become visible to Vim after this call.
" Run ":PlugInstall" to install.
call plug#end()

au VimEnter,VimResume * set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
  \,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
  \,sm:block-blinkwait175-blinkoff150-blinkon175

au VimLeave,VimSuspend * set guicursor=a:ver25-blinkon0

set number
set relativenumber
set tabstop=4
set shiftwidth=4
syntax on
set mouse=a
set ttyfast
" set noswapfile
