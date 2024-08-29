local M = {}
local api = vim.api
local diagnostic = vim.diagnostic
local utils = require("norminette.utils")

-- Create a unique namespace for norminette diagnostics
local namespace = api.nvim_create_namespace("norminette")

-- Function to run norminette and update diagnostics
function M.norminette()
	-- Get the current buffer
	local buf = api.nvim_get_current_buf()

	-- Check if the buffer's filetype is valid
	local filetype = vim.bo[buf].filetype
	if filetype ~= "c" and filetype ~= "h" then
		return
	end

	-- Create a temporary file with the buffer content
	local temp_file, err = utils.create_temp_file(buf)
	if not temp_file then
		vim.notify("Failed to create temporary file: " .. err, vim.log.levels.ERROR)
		return
	end

	-- Run norminette on the temporary file
	local output, run_err = utils.run_norminette(temp_file)
	if run_err then
		vim.notify(run_err, vim.log.levels.ERROR)
		return
	end

	-- Delete the temporary file
	os.remove(temp_file)

	-- Define a table to hold the diagnostics
	local diagnostics = {}

	if output == nil then
		return
	end
	-- Check if the output indicates the file is clear
	if output:match("OK!") then
		vim.notify("Norminette: PASS!", vim.log.levels.INFO)
	else
		vim.notify("Norminette: FAIL!", vim.log.levels.INFO)
	end

	-- Remove the first line
	output = output:gsub("^[^\r\n]+[\n\r]", "")

	-- Parse the output into Neovim diagnostics
	for line in output:gmatch("[^\r\n]+") do
		-- Trim the message
		local trim_str = line:gsub("^%s*", "")
		-- Extract and classify messages
		local line_number, col, message = trim_str:match("line:%s*(%d+),%s*col:%s*(%d+)%):%s*(.*)")
		local severity

		if line:match("^Notice:") then
			severity = diagnostic.severity.WARN
		else
			-- Default to error if message type is unrecognized
			severity = diagnostic.severity.ERROR
		end

		table.insert(diagnostics, {
			lnum = tonumber(line_number or "1") - 1, -- Neovim uses 0-based indexing
			col = tonumber(col or "1") - 1,
			severity = severity,
			message = message or trim_str,
		})
	end

	-- Add the new diagnostics without clearing the existing ones
	diagnostic.set(namespace, buf, diagnostics, { virtual_text = true })
end

-- Function to attach to buffer and handle events
function M.attach_to_buffer()
	local buf = api.nvim_get_current_buf()

	-- Check if the buffer's filetype is valid
	local filetype = vim.bo[buf].filetype
	if filetype ~= "c" and filetype ~= "h" then
		return
	end

	-- Attach to the buffer to monitor changes
	api.nvim_buf_attach(buf, false, {
		on_lines = function(_, _, _, _, _, _)
			-- Only run Norminette when exiting insert mode
			if vim.fn.mode() == "n" then
				vim.schedule(function()
					M.norminette()
				end)
			end
		end,
		on_detach = function(_, buff)
			vim.notify("Norminette detached from buffer " .. buff, vim.log.levels.INFO)
		end,
	})
end

return {
	norminette = M.norminette,
	attach_to_buffer = M.attach_to_buffer,
}
