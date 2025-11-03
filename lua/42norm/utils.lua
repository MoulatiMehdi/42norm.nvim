local M = {}
local api = vim.api

-- Default configuration
local config = require("42norm.config")

function M.get_extension(buf)
	return api.nvim_buf_get_name(buf):match("%.([%a%d]+)$") or nil
end

function M.command_exists(cmd)
	local handle = io.popen("command -v " .. cmd .. " > /dev/null 2>&1 && echo 'true' || echo 'false'")
	if not handle then
		return nil
	end

	local result = handle:read("*a")
	handle:close()
	return result:match("true") ~= nil
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

	local fd = io.open(temp_file, "wb")
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

function M.run_norminette(temp_file, on_complete)
    local command
    if vim.fn.has("win32") == 1 then
        command = "norminette " .. temp_file .. " 2> NUL"
    else
        command = "norminette " .. temp_file .. " 2> /dev/null "
    end

    local output = {}
    local timed_out = false
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
            if timed_out and not err then
                err = "Timed out"
            end
            if on_complete then
                on_complete(result and strip_color_codes(result) or nil, err)
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
            if timed_out then
                return
            end
            finish(table.concat(output, "\n"), nil)
        end,
    })

    if not job_id or job_id <= 0 then
        finish(nil, "Failed to start norminette command.")
        return
    end

    -- Start timeout timer
    timer:start(config.config.timeout, 0, function()
        timed_out = true
        pcall(vim.fn.jobstop, job_id)
        finish(nil, "timeout")
    end)
end

return M
