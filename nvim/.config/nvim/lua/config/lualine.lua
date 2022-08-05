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
      lualine_b = {'branch', 'diff', 'diagnostics'},
      lualine_c = { {
          'filename',
          symbols = {
              unnamed = "[Untitled]"
          }
      } },
      lualine_x = {'filetype', 'encoding'},
      lualine_y = {},
      lualine_z = {'location'}
  },
}

require('lualine').setup(options)
