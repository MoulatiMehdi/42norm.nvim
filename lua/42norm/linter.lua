local M = {}
local api = vim.api
local config = require("42norm.config")
local utils = require("42norm.utils")
local linter_handlers = require("42norm.handlers.c_handler")

-- Track running checks per buffer to avoid overlap
local running_checks_by_buf = {}

local function is_ignored(buf)
	local cfg = config.get_config()
	local ignore_list = cfg.ignore or {}
	local name = api.nvim_buf_get_name(buf)
	if not name or name == "" then
		return false
	end
	local basename = name:match("([^/\\]+)$")
	if not basename then
		return false
	end
	for _, ignored in ipairs(ignore_list) do
		if basename == ignored then
			return true
		end
	end
	return false
end

-- Function to run norminette and update diagnostics
function M.norminette(filename, linter, linter_handler)
	-- Get the current buffer
	local buf = filename or api.nvim_get_current_buf()

	if is_ignored(buf) then
		return
	end

	-- Avoid overlapping checks
	if running_checks_by_buf[buf] then
		return
	end
	running_checks_by_buf[buf] = true

	-- Create a temporary file with the buffer content
	local temp_file, err = utils.create_temp_file(buf)
	if not temp_file then
		running_checks_by_buf[buf] = nil
		vim.notify("Failed to create temporary file: " .. err, vim.log.levels.ERROR)
		return
	end

	-- Run norminette asynchronously on the temporary file
	utils.lint(temp_file, linter, function(output, run_err)
		pcall(os.remove, temp_file)
		running_checks_by_buf[buf] = nil
		local diagnostics = linter_handler(output, run_err)

		-- Create a unique namespace for norminette diagnostics
		local namespace = vim.api.nvim_create_namespace(linter)
		vim.diagnostic.set(namespace, buf, diagnostics or {}, { virtual_text = true })
	end)
end

-- Function to attach to buffer and handle events
function M.attach_to_buffer()
	local buf = api.nvim_get_current_buf()

	-- Check if the buffer's filetype is valid

	if is_ignored(buf) then
		return
	end

	-- Attach to the buffer to monitor changes
	api.nvim_buf_attach(buf, false, {
		on_lines = function(_, _, _, _, _, _)
			-- Only run Norminette when exiting insert mode
			if vim.fn.mode() ~= "i" then
				vim.schedule(function()
					local filetype = utils.get_extension(buf)
					if filetype ~= "c" and filetype ~= "h" then
						M.norminette(buf, "norminette", linter_handlers.handle_c())
					end
				end)
			end
		end,
		on_detach = function(_, buff)
			vim.notify("Norminette detached from buffer " .. buff, vim.log.levels.INFO)
		end,
	})
end

return {
	check = M.norminette,
	attach_to_buffer = M.attach_to_buffer,
}
