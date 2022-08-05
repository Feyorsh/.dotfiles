local options = {
  ensure_installed = {
    'lua',
	'vim',
	'c',
	'cpp',
	'rust',
	'python',
	'html',
	'latex',
	'markdown',
  },
  auto_install = true,
  highlight = {
    enable = true,
    use_languagetree = true,
  },
}

require("nvim-treesitter.configs").setup(options)
