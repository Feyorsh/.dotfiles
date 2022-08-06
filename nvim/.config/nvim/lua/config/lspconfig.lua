require("lspconfig").ccls.setup {}
require("lspconfig").rust_analyzer.setup {}
require("lspconfig").pyright.setup {}
require("lspconfig").gopls.setup {}
require("lspconfig").texlab.setup {
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
}
require("lspconfig").sumneko_lua.setup {
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
}
