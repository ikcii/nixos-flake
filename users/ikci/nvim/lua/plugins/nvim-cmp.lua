return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"saadparwaiz1/cmp_luasnip",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
	},

	config = function()
		local cmp = require("cmp")
		local luasnip = require("luasnip")

		-- Setup nvim-cmp
		cmp.setup({
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},
			window = {
				completion = cmp.config.window.bordered(),
				documentation = cmp.config.window.bordered(),
			},
			mapping = cmp.mapping.preset.insert({
				["<C-n>"] = cmp.mapping.select_next_item(),
				["<C-p>"] = cmp.mapping.select_prev_item(),
				["<C-b>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete(),
				["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item
			}),
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "luasnip" },
			}, {
				{ name = "buffer" },
				{ name = "path" },
			}),
		})

		-- Helper function to start a server
		local function start_lsp(config)
			-- Merge default capabilities (for cmp autocomplete support)
			local defaults = {
				capabilities = require("cmp_nvim_lsp").default_capabilities(),
				-- Default root detection: look for .git, flake.nix, or current dir
				root_dir = vim.fs.root(0, { ".git", "flake.nix", "pyproject.toml", "package.json" }) or
				    vim.loop.cwd(),
			}

			-- Merge user config into defaults
			local final_config = vim.tbl_deep_extend("force", defaults, config)

			-- Start the client (re-uses existing client if already running)
			vim.lsp.start(final_config)
		end

		-- Define Autocommands to launch servers per filetype
		local lsp_group = vim.api.nvim_create_augroup("mnw-lsp-start", { clear = true })

		-- Helper to make the autocommands cleaner
		local function on_ft(filetypes, config)
			vim.api.nvim_create_autocmd("FileType", {
				pattern = filetypes,
				group = lsp_group,
				callback = function()
					start_lsp(config)
				end,
			})
		end

		-- Nix (nil)
		on_ft("nix", {
			name = "nil",
			cmd = { "nil" },
			settings = {
				['nil'] = {
					formatting = { command = { "nixfmt" } },
				},
			},
		})

		-- Python (pyright)
		on_ft("python", {
			name = "pyright",
			cmd = { "pyright-langserver", "--stdio" },
		})

		-- Bash (bashls)
		on_ft("sh", {
			name = "bashls",
			cmd = { "bash-language-server", "start" },
		})

		-- Lua (lua_ls)
		on_ft("lua", {
			name = "lua_ls",
			cmd = { "lua-language-server" },
			settings = {
				Lua = {
					runtime = { version = "LuaJIT" },
					workspace = {
						checkThirdParty = false,
						library = { vim.env.VIMRUNTIME },
					},
					completion = { callSnippet = "Replace" },
					diagnostics = { globals = { "vim" } },
				},
			},
		})

		-- GDScript (godot)
		on_ft("gdscript", {
			name = "godot",
			cmd = vim.lsp.rpc.connect('127.0.0.1', tonumber(os.getenv 'GDScript_Port' or '6005'))
		})

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("mnw-lsp-attach", { clear = true }),
			callback = function(event)
				local map = function(keys, func, desc)
					vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
				end

				map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
				map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
				map("K", vim.lsp.buf.hover, "Hover Documentation")
				map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
				map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

				vim.api.nvim_create_autocmd("BufWritePre", {
					buffer = event.buf,
					callback = function() vim.lsp.buf.format() end
				})
			end,
		})
	end,
}
