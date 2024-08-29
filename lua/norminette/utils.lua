local M = {}
local api = vim.api

-- Function to create a temporary file with the same extension as the buffer's file or default to .c
function M.create_temp_file(buf)
	-- Get the buffer content
	local content = api.nvim_buf_get_lines(buf, 0, -1, false)
	local file_content = table.concat(content, "\n") .. "\n"

	-- Get the buffer's file name and extension
	local file_name = api.nvim_buf_get_name(buf)
	local file_ext = file_name:match("%.([%a%d]+)$") or "c" -- Default to .c if no extension found

	-- Create a temporary file with the same extension as the buffer file or default to .c
	local temp_file = vim.fn.tempname() .. "." .. file_ext

	local fd = io.open(temp_file, "w")
	if not fd then
		error("Failed to open temporary file for writing.")
	end

	-- Write content to the temporary file
	fd:write(file_content)
	fd:close()

	return temp_file
end

local function strip_color_codes(text)
	return text:gsub("\027%[%d+m", ""):gsub("\027%[%d;%dm", ""):gsub("\027%[%d;%d;%dm", "")
end

-- Function to run norminette on the file and return output and error
function M.run_norminette(temp_file)
	local handle = io.popen("norminette " .. temp_file)
	if not handle then
		return nil, "Failed to run norminette."
	end
	local output = handle:read("*a")
	local success, exit_code = handle:close()

	if not success then
		return nil, "Error running norminette."
	end

	return strip_color_codes(output), nil
end

-- Function to strip color codes from the output

return M
