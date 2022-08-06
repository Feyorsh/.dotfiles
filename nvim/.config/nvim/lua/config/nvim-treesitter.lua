local options = {
  ensure_installed = {
    'lua',
	'vim',
	'c',
	'cpp',
	'rust',
	'python',
	'html',
	'markdown',
  },
  highlight = {
    enable = true,
	disable = {
		'latex'
	},
    use_languagetree = true,
  },
}

require("nvim-treesitter.configs").setup(options)
