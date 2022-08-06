local M = {}

M.luasnip = function()
	require('luasnip').setup {
		history = true,
		updateevents = "TextChanged,TextChangedI"
	}
	require("luasnip.loaders.from_vscode").lazy_load()

	vim.api.nvim_create_autocmd("InsertLeave", {
		callback = function()
			if require("luasnip").session.current_nodes[vim.api.nvim_get_current_buf()] and not require("luasnip").session.jump_active
			then
				require("luasnip").unlink_current()
			end
		end,
	})
end

M.blankline = function()
	require('indent_blankline').setup {
		indentLine_enabled = 1,
		filetype_exclude = {
			"help",
			"terminal",
			"alpha",
			"packer",
			"lspinfo",
			"TelescopePrompt",
			"TelescopeResults",
			"Mason",
			"",
		},
		buftype_exclude = { "terminal" },
		show_trailing_blankline_indent = false,
		show_first_indent_level = false,
		show_current_context = true,
		show_current_context_start = true,
	}
end

return M
