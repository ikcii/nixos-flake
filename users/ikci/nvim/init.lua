vim.g.mapleader = " "

require("lazy").setup({
	dev = {
		path = mnw.configDir .. "/pack/mnw/opt",
		patterns = { "" },
		fallback = false,
	},

	performance = {
		reset_packpath = false,
		rtp = {
			reset = false,
		},
	},

	install = {
		missing = false,
	},

	spec = {
		-- { import = "plugins" },
	}
})
