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

	if config.config.lint_on_change then
		-- Autocommand to attach Norminette to buffers of type .c and .h
		vim.api.nvim_create_autocmd("BufEnter", {
			pattern = { "*.c", "*.h" },
			callback = function()
				linter.attach_to_buffer()
			end,
			desc = "Attach Norminette to buffer on BufEnter",
		})
		-- Autocommand to run Norminette when exiting insert mode
		vim.api.nvim_create_autocmd({ "InsertLeave" }, {
			pattern = { "*.c", "*.h" },
			callback = function()
				linter.check()
			end,
			desc = "Run Norminette on buffer when exiting insert mode",
		})
	end
end

-- Autocommand to run Norminette when exiting insert mode
vim.api.nvim_create_autocmd({ "BufEnter" }, {
	pattern = { "*.c", "*.h" },
	callback = function()
		linter.check()
	end,
	desc = "Run Norminette on buffer when exiting insert mode",
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = header.update,
})

return M
