vim.cmd([[
	augroup packer_user_config
		autocmd!
		autocmd BufWritePost plugins.lua source <afile> | PackerUpdate 
	augroup end
]])

local use = require('packer').use
return require('packer').startup(function()
	-- dependencies
	use 'wbthomason/packer.nvim'
	use 'nvim-lua/plenary.nvim'
	use 'kyazdani42/nvim-web-devicons'

	-- essentials
	use { 
		"nvim-telescope/telescope.nvim",
		requires = { 'nvim-lua/plenary.nvim' },
		config = function() require('config.telescope') end
	}


	-- ui
	use {
		'kyazdani42/nvim-tree.lua',
		requires = { 'kyazdani42/nvim-web-devicons', opt = true },
		config = function() require('config.nvim-tree') end
	}
	use {
		'nvim-lualine/lualine.nvim',
		requires = { 'kyazdani42/nvim-web-devicons', opt = true },
		config = function() require('config.lualine') end
	}
	use 'akinsho/bufferline.nvim'

	use {
		'norcalli/nvim-colorizer.lua',
		config = function() require('colorizer').setup() end
	}
	use 'connorholyday/vim-snazzy'


	-- lsp / code completion
	use {
		'neovim/nvim-lspconfig',
		config = function() require('config.lspconfig') end
	}
	use {
		'nvim-treesitter/nvim-treesitter',
		run = ':TSUpdate',
		config = function() require('config.nvim-treesitter') end
	}
	use 'hrsh7th/nvim-cmp'


	-- editing
	use 'tpope/vim-surround'
	use {
		"windwp/nvim-autopairs",
		config = function() require("nvim-autopairs").setup() end
	}


	-- git
	use 'tpope/vim-fugitive'
	use {
		'lewis6991/gitsigns.nvim',
		requires = { 'nvim-lua/plenary.nvim' },
		config = function() require('config.gitsigns') end
	}
end)
