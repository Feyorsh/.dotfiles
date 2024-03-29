local servers = {
--	ccls = {}, -- transition to clangd
	clangd = {
		cmd = {
			"clangd",
		}
	},
--	rust_analyzer = {}, -- downloaded binary
	pyright = {}, -- python
	gopls = {}, -- go
	zls = {}, -- built from source, lives in /usr/local/bin
	texlab = { -- cargo
		settings = {
			texlab = {
				build = {
					executable = "tectonic",
					args = {
						"-X",
						"compile",
						"%f",
						"--synctex",
						"--keep-logs",
						"--keep-intermediates"
					},
					onSave = true
				}
			}
		}
	},
	sumneko_lua = { -- brew
		settings = {
			Lua = {
				runtime = {
					version = "LuaJIT"
				},
				diagnostics = {
					globals = { "vim" }
				}
			}
		}
	},
}

local floatGroup = vim.api.nvim_create_augroup("float_hl", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	command = [[highlight NormalFloat guibg=#1f2335]],
	group = floatGroup
})
vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	command = [[highlight FloatBorder guifg=white guibg=#1f2335]],
	group = floatGroup
})

local function border(hl_name)
  return {
    { "╭", hl_name },
    { "─", hl_name },
    { "╮", hl_name },
    { "│", hl_name },
    { "╯", hl_name },
    { "─", hl_name },
    { "╰", hl_name },
    { "│", hl_name },
  }
end

local function goto_definition(split_cmd)
	local util = vim.lsp.util
	local log = require("vim.lsp.log")
	local api = vim.api

	local handler = function(_, result, ctx)
		if result == nil or vim.tbl_isempty(result) then
			local _ = log.info() and log.info(ctx.method, "No location found")
			return nil
		end

		if split_cmd then
			vim.cmd(split_cmd)
		end

		if vim.tbl_islist(result) then
			util.jump_to_location(result[1])
			if #result > 1 then
				util.set_qflist(util.locations_to_items(result))
				api.nvim_command("copen")
				api.nvim_command("wincmd p")
			end
		else
			util.jump_to_location(result)
		end
	end

	return handler
end

local on_attach = function(client, bufnr)
	-- Mappings.
	-- See `:help vim.lsp.*` for documentation on any of the below functions
	local bufopts = { buffer=bufnr, silent=true }
	vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)

	-- Jump to the definition
	vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)

	-- Jump to declaration
	vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)

	-- Lists all the implementations for the symbol under the cursor
	vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)

	-- Jumps to the definition of the type symbol
	vim.keymap.set('n', 'go', vim.lsp.buf.type_definition, bufopts)

	-- Lists all the references 
	vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)

	-- Displays a function's signature information
	vim.keymap.set('n', '<F4>', vim.lsp.buf.signature_help, bufopts)

	-- Renames all references to the symbol under the cursor
	vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, bufopts)

	-- Selects a code action available at the current cursor position
	vim.keymap.set('n', '<C-k>', vim.lsp.buf.code_action, bufopts)
	vim.keymap.set('x', '<C-k>', vim.lsp.buf.range_code_action, bufopts)

	-- Show diagnostics in a floating window
	vim.keymap.set('n', ';d', vim.diagnostic.open_float, bufopts)

	-- Move to the previous diagnostic
	vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, bufopts)

	-- Move to the next diagnostic
	vim.keymap.set('n', ']d', vim.diagnostic.goto_next, bufopts)

	-- autocmds
	-- SOL on CursorHold; see https://github.com/neovim/neovim/issues/12587
	-- ifi one really wanted this, I could use the proposed extension
	--		vim.api.nvim_create_autocmd("CursorHold", {
		--			buffer = bufnr,
		--			callback = function()
			--				local opts = {
				--					focusable = false,
				--					close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
				--					border = 'rounded',
				--					source = 'always',
				--					prefix = ' ',
				--					scope = 'cursor',
				--				}
				--				vim.diagnostic.open_float(nil, opts)
				--			end
				--		})
end

local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)

local lsp_defaults = {
	flags = {
		debounce_text_changes = 150
	},
	handlers = {
		["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {border = border("FloatBorder")}),
		["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {border = border("FloatBorder")}),
		["textDocument/definition"] = goto_definition("split")
	},
	on_attach = on_attach
}


local lspconfig = require('lspconfig')

lspconfig.util.default_config = vim.tbl_deep_extend(
  'force',
  lspconfig.util.default_config,
  lsp_defaults
)

vim.diagnostic.config({
	virtual_text = {
		source = "if_many",
	},
	float = {
		source = "if_many",
	},
	underline = true,
})


local config = function()
	for lsp, settings in pairs(servers) do
		lspconfig[lsp].setup(settings)
	end
end

local M = {
	servers = servers,
	config = config,
	on_attach = on_attach
}
return M
