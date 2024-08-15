local M = {}
local api = vim.api
local diagnostic = vim.diagnostic

-- Create a unique namespace for norminette diagnostics
local namespace = api.nvim_create_namespace("norminette")

-- Function to show a non-blocking notification
local function show_notification(message, level)
	vim.schedule_wrap(function()
		vim.notify(message, level, { title = "Norminette" })
	end)()
end

-- Function to run norminette and update diagnostics
function M.norminette()
	-- Get the current buffer's file name
	local file = vim.fn.expand("%:p")

	-- Check if the file is valid and has a .c or .h extension
	local ext = vim.fn.fnamemodify(file, ":e")
	if file == "" or (ext ~= "c" and ext ~= "h") then
		return
	end

	-- Run norminette command
	local handle = io.popen("norminette " .. file)
	if not handle then
		show_notification("Failed to run norminette.", vim.log.levels.ERROR)
		return
	end

	local output = handle:read("*a")
	handle:close()

	-- Extract filename for comparison
	local filename = vim.fn.fnamemodify(file, ":t") -- Extract the filename

	-- Define a table to hold the diagnostics
	local diagnostics = {}

	-- Check if the output indicates the file is clear
	if output:match(filename .. ": OK!") then
		-- Clear only norminette diagnostics for the buffer
		diagnostic.set(namespace, 0, {})
		show_notification("Norminette: PASS!", vim.log.levels.INFO)
	else
		show_notification("Norminette: FAIL!", vim.log.levels.ERROR)

		-- Parse the output into Neovim diagnostics
		for line in output:gmatch("[^\r\n]+") do
			-- Extract line number, column, and message
			local line_number, col, message = line:match("line:%s*(%d+),%s*col:%s*(%d+)%):%s*(.*)")
			if line_number and message and col then
				table.insert(diagnostics, {
					lnum = tonumber(line_number) - 1, -- Neovim uses 0-based indexing
					col = tonumber(col) - 1,
					severity = diagnostic.severity.ERROR,
					message = message,
				})
			elseif message then
				table.insert(diagnostics, {
					lnum = 0,
					col = 0,
					severity = diagnostic.severity.ERROR,
					message = line,
				})
			end
		end

		-- Set the diagnostics in the norminette namespace
		diagnostic.set(namespace, 0, diagnostics) -- `0` for current buffer and norminette namespace
	end
end

return M
