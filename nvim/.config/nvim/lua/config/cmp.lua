local M = {}


local has_words_before = function()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

M.setup = function()
	local cmp = require('cmp')
	local luasnip = require('luasnip')
	cmp.setup {
		snippet = {
			expand = function(args)
				require('luasnip').lsp_expand(args.body)
			end,
		},
		formatting = {
			fields = {'abbr', 'kind', 'menu' },
			format = require('lspkind').cmp_format {
				mode = 'symbol_text',
				menu = ({
					buffer = "[Buffer]",
					nvim_lsp = "[LSP]",
					luasnip = "[LuaSnip]",
					nvim_lua = "[Lua]",
					latex_symbols = "[Latex]",
				})
			}
		},
		window = {
			completion = cmp.config.window.bordered(),
			documentation = cmp.config.window.bordered()
		},
		mapping = {
			['<Up>'] = cmp.mapping.select_prev_item(),
			['<Down>'] = cmp.mapping.select_next_item(),
			["<S-Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_prev_item()
				elseif luasnip.jumpable(-1) then
					luasnip.jump(-1)
				else
					fallback()
				end
			end, { "i", "s" }),
			["<Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_next_item()
				elseif luasnip.expand_or_jumpable() then
					luasnip.expand_or_jump()
				elseif has_words_before() then
					cmp.complete()
				else
					fallback()
				end
			end, { "i", "s" }),
			['<C-k>'] = cmp.mapping.scroll_docs(-4),
			['<C-j>'] = cmp.mapping.scroll_docs(4),
			['<Esc>'] = cmp.mapping({
				c = function()
					if cmp.visible() then
						cmp.abort()
					else
						-- see https://github.com/hrsh7th/nvim-cmp/issues/1033
						vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-c>', true, true, true), 'n', true)
					end
				end,
				i = function(fallback)
					if cmp.visible() then
						cmp.abort()
					else
						fallback()
					end
				end
			}),
			['<CR>'] = cmp.mapping.confirm({
				behavior = cmp.ConfirmBehavior.Insert,
				select = false
			})
		},
		-- Installed sources
		sources = {
			{
				name = 'nvim_lsp',
				max_item_count = 5,
				keyword_length = 3
			},
			{
				name = 'nvim_lua',
				max_item_count = 3,
				keyword_length = 3
			},
			{
				name = 'luasnip',
				max_item_count = 2,
				keyword_length = 3
			},
			{
				name = 'buffer',
				max_item_count = 2,
				keyword_length = 2
			},
			{
				name = 'path',
				max_item_count = 2,
				keyword_length = 2
			},
			{
				name = 'spell',
				max_item_count = 3,
				keyword_length = 4
			},
		},
	}

	-- autopairs
	cmp.event:on {
		'confirm_done',
		require('nvim-autopairs.completion.cmp').on_confirm_done()
	}
end

M.lspconfig = function()
	local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

	for lsp, config in pairs(require('config.lspconfig').servers) do
		config['capabilities'] = capabilities
		require('lspconfig')[lsp].setup(config)
	end
end
return M
