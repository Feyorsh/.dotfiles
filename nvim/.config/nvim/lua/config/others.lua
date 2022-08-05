-- autopairs
local present1, autopairs = pcall(require, "nvim-autopairs")
local present2, cmp = pcall(require, "cmp")

if not (present1 and present2) then
	return
end

local options = {
	fast_wrap = {},
	disable_filetype = { "TelescopePrompt", "vim" },
}

autopairs.setup(options)

local cmp_autopairs = require "nvim-autopairs.completion.cmp"
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())


M.colorizer = function()
  local present, colorizer = pcall(require, "colorizer")

  if not present then
    return
  end

  local options = {
    filetypes = {
      "*",
    },
    user_default_options = {
      RGB = true, -- #RGB hex codes
      RRGGBB = true, -- #RRGGBB hex codes
      names = false, -- "Name" codes like Blue
      RRGGBBAA = false, -- #RRGGBBAA hex codes
      rgb_fn = false, -- CSS rgb() and rgba() functions
      hsl_fn = false, -- CSS hsl() and hsla() functions
      css = false, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
      css_fn = false, -- Enable all CSS *functions*: rgb_fn, hsl_fn
      mode = "background", -- Set the display mode.
    },
  }

  colorizer.setup(options["filetypes"], options["user_default_options"])

  -- unsure if I want to do an autocmd or lazy load this
  vim.cmd "ColorizerAttachToBuffer"
end

-- gitsigns
local present, gitsigns = pcall(require, "gitsigns")

if not present then
	return
end

local options = {
	signs = {
	  add = { hl = "DiffAdd", text = "│", numhl = "GitSignsAddNr" },
	  change = { hl = "DiffChange", text = "│", numhl = "GitSignsChangeNr" },
	  delete = { hl = "DiffDelete", text = "", numhl = "GitSignsDeleteNr" },
	  topdelete = { hl = "DiffDelete", text = "‾", numhl = "GitSignsDeleteNr" },
	  changedelete = { hl = "DiffChangeDelete", text = "~", numhl = "GitSignsChangeNr" },
	},
}

gitsigns.setup(options)
