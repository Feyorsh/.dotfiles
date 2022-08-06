require('bufferline').setup {
	options = {
    	mode = "buffers",
		offsets = {
			{
				filetype = "NvimTree",
				text = function() return vim.fn.getcwd() end,
				highlight = "Directory"
			}
		}
	}
}
