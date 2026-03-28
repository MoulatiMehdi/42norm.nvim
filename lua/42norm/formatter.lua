local M = {}
local utils = require("42norm.utils")

function M.format()
	-- Create a temporary file with the buffer content
	local buf = vim.api.nvim_get_current_buf()
	local filetype = utils.get_extension(buf)
	if filetype ~= "c" and filetype ~= "h" then
		return
	end
	local temp_file, err = utils.create_temp_file(buf)
	if not temp_file then
		vim.notify("Failed to create temporary file: " .. err, vim.log.levels.ERROR)
		return
	end

	-- Run the formatter command directly on the temporary file
	local cmd = "c_formatter_42 "
	if vim.fn.has("win32") == 1 then
		cmd = cmd .. temp_file .. " 2> NUL"
	else
		cmd = cmd .. temp_file .. " 2> /dev/null"
	end
	local handle = io.popen(cmd)

	-- Check if the handle was created successfully
	if not handle then
		vim.notify("Failed to execute the formatter command.", vim.log.levels.ERROR)
		os.remove(temp_file)
		return
	end

	-- Close the handle and check for success
	local success = handle:close()
	if not success then
		vim.notify("Failed to format the code. Please ensure that c_formatter_42 is installed.", vim.log.levels.ERROR)
		os.remove(temp_file)
		return
	end

	-- Attempt to open the formatted file
	local formatted_file = io.open(temp_file, "r")
	if not formatted_file then
		vim.notify("Failed to read the formatted file.", vim.log.levels.ERROR)
		os.remove(temp_file)
		return
	end

	-- Read the formatted content
	local formatted_content = formatted_file:read("*a")
	formatted_file:close()

	-- Split the content into lines and remove any trailing empty lines
	local lines = vim.split(formatted_content, "\n")
	if lines[#lines] == "" then
		table.remove(lines, #lines)
	end

	-- Replace buffer content with formatted result
	vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)

	-- Delete the temporary file
	os.remove(temp_file)
end

return M
