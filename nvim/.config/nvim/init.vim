lua require('plugins')

au VimEnter,VimResume * set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
  \,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
  \,sm:block-blinkwait175-blinkoff150-blinkon175

au VimLeave,VimSuspend * set guicursor=a:ver25-blinkon0

let g:SnazzyTransparent = 1
colorscheme snazzy

lua << EOF
vim.api.nvim_set_keymap('', '<Space>', '<Nop>', { noremap = true, silent = true })
EOF

" I'm not super jazzed to be adding more Vimscript, but eh. Quickfix is
" annoying enough.
au BufEnter * call MyLastWindow()
function! MyLastWindow()
  " if the window is quickfix go on
  if &buftype=="quickfix"
    " if this window is last on screen quit without warning
    if winbufnr(2) == -1
      quit!
    endif
  endif
endfunction

let g:tex_flavor = 'latex'
let g:vimtex_view_enabled = 1
let g:vimtex_view_method = 'skim'
let g:vimtex_view_skim_sync = 1
let g:vimtex_compiler_method = 'tectonic'

let g:mapleader = " "

set signcolumn=yes
set spellsuggest=best,5
set spelllang=en,cjk
nnoremap <silent> <leader>s :set spell!<cr>

tnoremap <leader><Esc> <C-\><C-n>
set completeopt=menuone,noselect,noinsert
set splitright " see https://github.com/kyazdani42/nvim-tree.lua/issues/1103
set whichwrap+=<,>,[,]
let &fcs='eob: '
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
