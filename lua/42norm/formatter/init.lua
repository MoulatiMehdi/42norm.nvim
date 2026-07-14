local M = {}
local utils = require("42norm.utils")

function M.format(formatter_cmd)
	-- Create a temporary file with the buffer content
	local buf = vim.api.nvim_get_current_buf()
	local temp_file, err = utils.create_temp_file(buf)
	if not temp_file then
		vim.notify("Failed to create temporary file: " .. err, vim.log.levels.ERROR)
		return
	end

    local cmd
	-- Run the formatter command directly on the temporary file
	if vim.fn.has("win32") == 1 then
		cmd = formatter_cmd .." " .. temp_file .. " 2> NUL"
	else
		cmd = formatter_cmd .." " .. temp_file .. " 2> /dev/null"
	end
	local handle,err = io.popen(cmd)

	-- Check if the handle was created successfully
	if not handle then
		vim.notify("Failed to execute `" .. cmd .. "` command.", vim.log.levels.ERROR)
		os.remove(temp_file)
		return
	end

	-- Close the handle and check for success
	local success = handle:close()
	if not success then
		vim.notify("Failed to format the code. Please ensure that `" .. cmd .. "` is installed.", vim.log.levels.ERROR)
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
    vim.bo.modified = false
end

return M
