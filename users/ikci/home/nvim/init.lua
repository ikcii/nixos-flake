-- Huge thanks to nvim-lua/kickstart.nvim (MIT license) and Gerg-L/mnw (MIT license)

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = true

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.showmode = false

vim.schedule(function()
	vim.opt.clipboard = 'unnamedplus'
end)

vim.opt.breakindent = true

vim.opt.expandtab = false
vim.opt.tabstop = 8
vim.opt.shiftwidth = 8
vim.opt.softtabstop = 0
vim.opt.smartindent = true

vim.opt.undofile = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.updatetime = 250

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

vim.opt.inccommand = 'split'

vim.opt.cursorline = true

vim.opt.scrolloff = 12

vim.opt.confirm = true

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.api.nvim_create_autocmd('TextYankPost', {
	desc = 'Highlight when yanking (copying) text',
	group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- TODO: Potentially add logic for standalone mode
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
		import = "plugins",
	},

	rocks = {
		enabled = false,
	},

	checker = {
		enabled = false,
	},
})

vim.lsp.config('*', {
	capabilities = require('blink.cmp').get_lsp_capabilities(),
})

local lsp_configs = vim.api.nvim_get_runtime_file("lsp/*.lua", true)

for _, config_path in ipairs(lsp_configs) do
	local server_name = vim.fn.fnamemodify(config_path, ":t:r")

	-- Optional: Skip specific files if you ever add utility scripts to that folder
	if server_name ~= "utils" then
		vim.lsp.enable(server_name)
	end
end

vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		-- If the client supports formatting, setup a save hook
		if client.server_capabilities.documentFormattingProvider then
			vim.api.nvim_create_autocmd("BufWritePre", {
				buffer = args.buf,
				callback = function()
					vim.lsp.buf.format({ async = false, id = args.data.client_id })
				end,
			})
		end
	end,
})
