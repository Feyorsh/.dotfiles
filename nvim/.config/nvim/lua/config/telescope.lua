local M = {}

M.main = function()
	require('telescope').setup {
		pickers = {
			find_files = {
				hidden = true
			}
		}
	}
end

M.fzy = function()
	require('telescope').load_extension('fzy_native')
end

return M
