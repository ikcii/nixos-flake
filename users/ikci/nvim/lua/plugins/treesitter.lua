return {

	"nvim-treesitter/nvim-treesitter",

	lazy = false,

	opts = {
		auto_install = false,
	},

	-- TODO: Potentially add logic for standalone mode
	init = function()
    		require("nvim-treesitter.install").compilers = { "nvim" }
  	end,
}
