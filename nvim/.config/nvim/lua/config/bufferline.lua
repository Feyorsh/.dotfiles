require('bufferline').setup {
	options = {
    	mode = "buffers",
		numbers = "buffer_id",
		offsets = {
			{
				filetype = "NvimTree",
				text = function()
					local path = vim.fn.fnamemodify(vim.fn.getcwd(), ':~')
					local i = false
					local newstr = ""
					for c in string.gmatch(string.reverse(path), ".") do
						if c == "/" then
							if i then
								break
							end
							i = true
						end
						newstr = c .. newstr
					end
					return newstr
				end,
				highlight = "NvimTreeRootFolder"
			},
			{ filetype = "packer" }
		},
	}
}
