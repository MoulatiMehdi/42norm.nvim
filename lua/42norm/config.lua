local M = {}
-- Default configuration
M.config = {
	timeout = 3000,
	format_on_save = false,
	header_on_save = false,
	lint_on_change = true,
	ignore = {},
}

-- Function to set user configuration
function M.setup(user_config)
	M.config = vim.tbl_deep_extend("force", M.config, user_config or {})
end

function M.get_config()
	return M.config
end

return M
