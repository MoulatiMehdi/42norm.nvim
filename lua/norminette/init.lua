local linter = require("norminette.linter")
local formatter = require("norminette.formatter")
local config = require("norminette.config")
local installer = require("norminette.install")
local header = require("norminette.42header")
local M = {}

M.check_norms = linter.check
M.format = formatter.format
M.stdheader = header.stdheader

function M.setup(user_config)
	-- 1. Merge user config with defaults
	config.setup(user_config)

	installer.ensure_tools_installed()
	-- 2. Use configuration to conditionally set behavior
	if config.config.format_on_save then
		-- Set up autocommand for formatOnSave
		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*.c,*.h",
			callback = function()
				formatter.format()
			end,
		})
	end

	if config.config.header_on_save then
		-- Set up autocommand for formatOnSave
		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*.c,*.h",
			callback = function()
				header.stdheader()
			end,
		})
	end
end
-- Autocommand to attach Norminette to buffers of type .c and .h
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = { "*.c", "*.h" },
	callback = function()
		linter.attach_to_buffer()
	end,
	desc = "Attach Norminette to buffer on BufEnter",
})

-- Autocommand to run Norminette when exiting insert mode
vim.api.nvim_create_autocmd({ "InsertLeave", "BufEnter" }, {
	pattern = { "*.c", "*.h" },
	callback = function()
		linter.check()
	end,
	desc = "Run Norminette on buffer when exiting insert mode",
})

-- User command to manually run Norminette on the whole file
vim.api.nvim_create_user_command("Norminette", function()
	linter.check()
end, { desc = "Run Norminette on the whole file" })

-- User command to manually format the current buffer
vim.api.nvim_create_user_command("Format", function()
	formatter.format()
end, { desc = "Format the current buffer using 42 norms" })

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = header.update,
})

return M
