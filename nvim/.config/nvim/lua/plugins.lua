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
		'nvim-telescope/telescope.nvim',
		requires = { 'nvim-lua/plenary.nvim' },
		config = function() require('config.telescope') end
	}


	-- ui
	use {
		'kyazdani42/nvim-tree.lua',
		requires = { 'kyazdani42/nvim-web-devicons' },
		config = function() require('config.nvim-tree') end
	}
	use {
		'nvim-lualine/lualine.nvim',
		requires = { 'kyazdani42/nvim-web-devicons' },
		config = function() require('config.lualine') end
	}
	use {
		'akinsho/bufferline.nvim',
		config = function() require('config.bufferline') end
	}

	use {
		'lukas-reineke/indent-blankline.nvim',
		config = function() require('config.others').blankline() end
	}
	use {
		'norcalli/nvim-colorizer.lua',
		event = 'VimEnter',
		config = function() require('config.others').colorizer() end
	}
	use 'connorholyday/vim-snazzy'


	-- lsp / code completion
	use {
		'neovim/nvim-lspconfig',
		config = function() require('config.lspconfig').config() end
	}
	use {
		'nvim-treesitter/nvim-treesitter',
		run = ':TSUpdate',
		config = function() require('config.nvim-treesitter') end
	}

	-- cmp
	use {
		'rafamadriz/friendly-snippets',
		event = "InsertEnter",
	}
	use {
		'onsails/lspkind.nvim',
		after = 'friendly-snippets'
	}
	use {
		'L3MON4D3/LuaSnip',
		wants = 'friendly-snippets',
		after = 'lspkind.nvim',
		config = function() require('config.others').luasnip() end
	}
	use {
		'hrsh7th/nvim-cmp',
		after = 'LuaSnip',
		config = function() require('config.cmp').setup() end
	}
	use {
		'saadparwaiz1/cmp_luasnip',
		after = 'nvim-cmp',
	}
	use {
		'hrsh7th/cmp-nvim-lua',
		after = 'cmp_luasnip',
	}
	use {
		'hrsh7th/cmp-nvim-lsp',
		after = 'cmp-nvim-lua',
		config = function() require('config.cmp').lspconfig() end
	}

	use {
		'hrsh7th/cmp-buffer',
		after = 'cmp-nvim-lsp',
	}
	use {
		'hrsh7th/cmp-path',
		after = 'cmp-buffer',
	}


	-- editing
	use 'tpope/vim-surround'
	use {
		"windwp/nvim-autopairs",
		config = function() require("nvim-autopairs").setup() end
	}


	-- git
	use {
		'tpope/vim-fugitive',
		cmd = { 'Git', 'Gstatus', 'Gblame', 'Gpush', 'Gpull' },
	}
	use {
		'lewis6991/gitsigns.nvim',
		requires = { 'nvim-lua/plenary.nvim' },
		config = function() require('config.gitsigns') end
	}


	-- lang specific
	use {
		'lervag/vimtex',
		ft = 'tex'
	}
	use {
		'simrat39/rust-tools.nvim',
		ft = 'rust',
		wants = 'nvim-lspconfig',
		config = function() require('config.langs').rust_tools() end
	}
end)
