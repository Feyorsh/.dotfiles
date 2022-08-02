execute pathogen#infect()

au VimEnter,VimResume * set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
  \,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
  \,sm:block-blinkwait175-blinkoff150-blinkon175

au VimLeave,VimSuspend * set guicursor=a:ver25-blinkon0

let g:SnazzyTransparent = 1
colorscheme snazzy
lua << EOF
require("lualine").setup {
	options = {
		theme = require('snazzy'), 
		sections = {
			lualine_a = {'mode'},
			lualine_b = {'branch', 'diff', 'diagnostics'},
			lualine_c = {'filename'},
			lualine_x = {'encoding', 'filetype'},
			lualine_y = {},
			lualine_z = {'location'}
		},
		globalstatus = true
	}
}
EOF

let NERDTreeShowHidden=1
let NERDTreeMouseMode=2

" Start NERDTree when Vim is started without file arguments.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists('s:std_in') | NERDTree | endif
" Exit Vim if NERDTree is the only window remaining in the only tab.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif


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
