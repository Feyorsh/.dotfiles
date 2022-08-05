lua require('plugins')

au VimEnter,VimResume * set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
  \,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
  \,sm:block-blinkwait175-blinkoff150-blinkon175

au VimLeave,VimSuspend * set guicursor=a:ver25-blinkon0

let g:SnazzyTransparent = 1
colorscheme snazzy

lua << EOF
local function get_short_cwd()
	return vim.fn.fnamemodify(vim.fn.getcwd(), ':~')
end
EOF



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
