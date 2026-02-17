local M = {}

function M.start(config)
	local capabilities = require("blink.cmp").get_lsp_capabilities()

	local final_config = vim.tbl_deep_extend("force", {
		capabilities = capabilities,
	}, config or {})

	vim.lsp.start(final_config)
end

return M
