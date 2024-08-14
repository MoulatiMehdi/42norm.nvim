-- lua/norminette/init.lua

local api = vim.api
local diagnostic = vim.diagnostic

-- Create a unique namespace for norminette diagnostics
local namespace = api.nvim_create_namespace("norminette")

-- Function to run norminette and update diagnostics
local function run_norminette()
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
		print("Failed to run norminette.")
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
	else
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
			end
		end

		-- Set the diagnostics in the norminette namespace
		diagnostic.set(namespace, 0, diagnostics) -- `0` for current buffer and norminette namespace
	end
end

-- Register the command
api.nvim_create_user_command("Norminette", run_norminette, { desc = "Run norminette and show errors in diagnostics" })

-- Run Norminette on text changes, insert mode changes, file save, and buffer enter
api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
	pattern = { "*.c", "*.h" },
	callback = function()
		run_norminette()
	end,
	desc = "Update Norminette diagnostics on text changes, file save, and file open",
})
