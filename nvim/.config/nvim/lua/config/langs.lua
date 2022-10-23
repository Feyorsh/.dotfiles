local M = {}

M.rust_tools = function()
	local rt = require('rust-tools')
	local options = {
		tools = {
			autoSetHints = true,
			inlay_hints = {
				show_parameter_hints = false,
				parameter_hints_prefix = "",
				other_hints_prefix = "",
			},
		},

		-- all the opts to send to nvim-lspconfig
		-- these override the defaults set by rust-tools.nvim
		-- see https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#rust_analyzer
		server = {
			-- on_attach is a callback called when the language server attachs to the buffer
			on_attach = function(_, bufnr)
				require('config.lspconfig').on_attach(_, bufnr)
				--local rtGroup = vim.api.nvim_create_augroup("rtConfig", { clear = true })
				--vim.api.nvim_create_autocmd({"BufEnter", "InsertLeave"}, {
				--	buffer = bufnr,
				--	command = [[silent! lua vim.lsp.codelens.refresh()]],
				--	group = rtGroup
				--})
				vim.keymap.set('n', 'K', rt.hover_actions.hover_actions, { buffer=bufnr, silent=true })
				vim.keymap.set('n', '<C-k>', rt.code_action_group.code_action_group, { buffer=bufnr, silent=true })
			end,
			settings = {
				-- to enable rust-analyzer settings visit:
				-- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
				["rust-analyzer"] = {
					-- enable clippy on save
					checkOnSave = {
						command = "clippy"
					},
				}
			}
		},
	}

	rt.setup(options)
end

-- what does texlab actually contribute? lol
M.vimtex = function()
	local vtex = vim.api.nvim_create_augroup("vimtex_cmds", { clear = true })

	vim.api.nvim_create_autocmd("BufWrite", {
		pattern = "*.tex",
		command = [[silent! VimtexCompile]],
		group = vtex
	})
	-- this idea of auto-passing is cool in theory, it just doesn't work yet.
--	vim.api.nvim_create_autocmd("User", {
--		pattern = "VimtexEventCompileSuccess",
--		callback = function()
--			for _, v in pairs(vim.fn.getqflist()) do
--				if string.find("rerun", string.lower(v['text'])) then
--					vim.api.nvim_command("VimtexCompile")
--				end
--			end
--		end,
--		group = vtex
--	})
end

return M
