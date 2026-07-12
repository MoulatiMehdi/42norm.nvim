local M = {}
local api = vim.api

-- Default configuration
local config = require("42norm.config")

function M.get_extension(buf)
	return api.nvim_buf_get_name(buf):match("%.([%a%d]+)$") or nil
end

-- Function to create a temporary file with the same extension as the buffer's file or default to .c
function M.create_temp_file(buf)
	-- Get the buffer content
	local content = api.nvim_buf_get_lines(buf, 0, -1, false)
	local file_content = table.concat(content, "\n") .. "\n"

	-- Get the filename without the path
	local original_name = vim.fn.expand("%:t")

	-- Create a temporary file with the same extension as the buffer file or default to .c
	local temp_file = vim.fn.tempname():gsub("[^/]*$", "") .. original_name

	local fd, err = io.open(temp_file, "wb")

	if not fd then
		error(err)
	end

	-- Write content to the temporary file
	fd:write(file_content)
	fd:close()

	return temp_file
end

function M.lint(temp_file, linter_cmd, on_complete)
	local command
	if vim.fn.has("win32") == 1 then
		command = linter_cmd .. " " .. temp_file .. " 2> NUL"
	else
		command = linter_cmd .. " " .. temp_file .. " 2> /dev/null "
	end

	local output = {}
	local is_timedout = false
	local job_id

	-- Create a timer to enforce timeout without blocking UI
	local timer = vim.loop.new_timer()

	local function finish(result, err)
		-- Ensure callback executes on main loop
		vim.schedule(function()
			if timer and not timer:is_closing() then
				timer:stop()
				timer:close()
			end
			if is_timedout and not err then
				err = "Timed out"
			end
			if on_complete then
				on_complete(result, err)
			end
		end)
	end

	job_id = vim.fn.jobstart(command, {
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
			if is_timedout then
				return
			end
			finish(table.concat(output, "\n"), nil)
		end,
	})

	if not job_id or job_id <= 0 then
		finish(nil, "Failed to start " .. linter_cmd .. " command.")
		return
	end

	-- Start timeout timer
	timer:start(config.config.timeout, 0, function()
		is_timedout = true
		pcall(vim.fn.jobstop, job_id)
		finish(nil, "timeout")
	end)
end

return M
