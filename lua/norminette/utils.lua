local M = {}
local api = vim.api

-- Default configuration
local config = require("norminette.config")

function M.get_extension(buf)
	return api.nvim_buf_get_name(buf):match("%.([%a%d]+)$") or nil
end

-- Function to create a temporary file with the same extension as the buffer's file or default to .c
function M.create_temp_file(buf)
	-- Get the buffer content
	local content = api.nvim_buf_get_lines(buf, 0, -1, false)
	local file_content = table.concat(content, "\n") .. "\n"

	-- Get the buffer's file name and extension
	local file_ext = ("." .. M.get_extension(buf)) or "" -- Default to .c if no extension found

	-- Create a temporary file with the same extension as the buffer file or default to .c
	local temp_file = vim.fn.tempname() .. file_ext

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
	return text:gsub("\027%[%d+m", ""):gsub("\027%[%d);%dm", ""):gsub("\027%[%d;%d;%dm", "")
end

function M.run_norminette(temp_file)
	local command
	if vim.fn.has("win32") == 1 then
		command = "norminette " .. temp_file .. " 2> NUL"
	else
		command = "norminette " .. temp_file .. " 2> /dev/null "
	end

	local output = {}
	local timed_out = false

	-- Start the command as a job
	local job_id = vim.fn.jobstart(command, {
		on_stdout = function(_, data)
			if data then
				for _, line in ipairs(data) do
					table.insert(output, line)
				end
			end
		end,
		on_stderr = function(_, data)
			if data then
				for _, line in ipairs(data) do
					table.insert(output, line)
				end
			end
		end,
		on_exit = function(_, _)
			if timed_out then
				vim.notify("Norminette : Timed out (Make sure you didn't missed a ';').", vim.log.levels.ERROR)
			end
		end,
	})

	if not job_id then
		return nil, "Failed to start norminette command."
	end

	-- Wait for the job to complete with a timeout
	local job_result = vim.fn.jobwait({ job_id }, config.config.timeout)

	-- Check the result of the job wait
	if job_result[1] == -1 then
		-- Job did not complete within the timeout
		timed_out = true
		vim.fn.jobstop(job_id) -- Stop the job
		return nil
	end

	-- Join the output
	return strip_color_codes(table.concat(output, "\n")), nil
end

return M
