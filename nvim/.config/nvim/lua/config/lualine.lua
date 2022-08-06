local options = {
  options = {
      theme = require("snazzy"),
      globalstatus = true,
      refresh = {
          statusline = 100
      },
      ignore_focus = {
          "nvim-tree"
      },
  },
  sections = {
      lualine_a = {'mode'},
      lualine_b = {
		  {
			  'branch',
			  separator = "",
			  padding = {
				  right = 0,
				  left = 1
			  }
		  },
		  'diff',
	  },
      lualine_c = {{
          'filename',
          symbols = {
              unnamed = "[Untitled]"
          }
      }},
	  lualine_x = {'diagnostics'},
      lualine_y = {'filetype', 'encoding'},
      lualine_z = {'location'}
  },
}

require('lualine').setup(options)
