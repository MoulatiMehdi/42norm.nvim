local config = require("42norm.config")
local header = require("42norm.header")
local handlers = require("42norm.handlers")
local utils = require("42norm.utils")
local linter = require("42norm.linter")
local M = {}
local attached_buffers = {}

M.format = function()
	local filetype = vim.bo.filetype
	if handlers[filetype] then
		handlers[filetype].format()
	end
end

M.check_norms = function()
	local filetype = vim.bo.filetype
	if handlers[filetype] then
		handlers[filetype].lint()
	end
end

-- Function to attach to buffer and handle events
function M.attach_to_buffer()
	local buf = vim.api.nvim_get_current_buf()
	local filetype = utils.resolve_filetype(buf)

	if not handlers[filetype] then
		return
	end

	if linter.is_ignored(buf) then
		return
	end

	if attached_buffers[buf] then
		return
	end

	attached_buffers[buf] = true
	-- Attach to the buffer to monitor changes
	vim.api.nvim_buf_attach(buf, false, {
		on_lines = function(_, _, _, _, _, _)
			-- Only run linter when exiting insert mode
			if vim.fn.mode() ~= "i" then
				vim.schedule(function()
					local filetype = utils.resolve_filetype(buf)
					handlers[filetype].lint()
				end)
			end
		end,
		on_detach = function(_, buff)
			vim.notify("linter detached from buffer " .. buff, vim.log.levels.INFO)
		end,
	})
	handlers[filetype].lint()
end

function M.refresh_buffer()
	local buf = vim.api.nvim_get_current_buf()
	local filetype = utils.resolve_filetype(buf)

	if not handlers[filetype] then
		return
	end

	if linter.is_ignored(buf) then
		return
	end

	handlers[filetype].lint()
end

function M.setup(user_config)
	-- 1. Merge user config with defaults
	config.setup(user_config)

	-- Set up autocommand for format on save
	if config.config.format_on_save then
		vim.api.nvim_create_autocmd("BufWritePre", {
			callback = function()
				local filetype = utils.resolve_filetype(vim.api.nvim_get_current_buf())
				if handlers[filetype] then
					handlers[filetype].format()
				end
			end,
		})
	end

	-- Set up autocommand for inserting a header on save
	if config.config.header_on_save then
		vim.api.nvim_create_autocmd("BufWritePre", {
			callback = function()
				header.stdheader()
			end,
		})
	end

	-- Set up autocommand for lint the code when exiting insert mode or when opening a file
	if config.config.lint_on_change then
		vim.api.nvim_create_autocmd("FileType", {
			callback = function()
				M.attach_to_buffer()
			end,
			pattern = { "c", "cpp", "python" },
			desc = "Attach linter to supported filetypes",
		})

		vim.api.nvim_create_autocmd("InsertLeave", {
			callback = function()
				M.refresh_buffer()
			end,
			desc = "Refresh diagnostics after editing",
		})
	end
end

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = header.update,
})

return M
