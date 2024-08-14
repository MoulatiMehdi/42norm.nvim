local function run_norminette()
	-- Get the current buffer's file name
	local file = vim.fn.expand("%:p")

	-- Check if the file is valid and has a .c or .h extension
	local ext = vim.fn.fnamemodify(file, ":e")
	if file == "" or (ext ~= "c" and ext ~= "h") then
		print("Invalid file type or no file to check.")
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

	-- Define a namespace specifically for norminette diagnostics
	local norminette_ns = vim.api.nvim_create_namespace("norminette")

	-- Check if the output indicates the file is clear
	if output:match(filename .. " : OK!") then
		print(filename .. " : OK!")
		-- Clear only norminette diagnostics for the buffer
		vim.diagnostic.set(norminette_ns, 0, {}) -- Clear diagnostics for the norminette namespace
	else
		-- Parse the output into Neovim diagnostics
		local diagnostics = {}
		for line in output:gmatch("[^\r\n]+") do
			-- Extract line number, column, and message
			local line_number, col, message =
				line:match("Error:%s*([%w_]+)%s*%((line:%s*(%d+),%s*col:%s*(%d+))%):%s*(.*)")
			if line_number and message then
				table.insert(diagnostics, {
					lnum = tonumber(line_number) - 1, -- Neovim uses 0-based indexing
					col = tonumber(col) - 1,
					severity = vim.diagnostic.severity.ERROR,
					message = message,
				})
			end
		end

		-- Set the diagnostics in the norminette namespace
		vim.diagnostic.set(norminette_ns, 0, diagnostics) -- `0` for current buffer and norminette namespace
	end
end

-- Register the command
vim.api.nvim_create_user_command(
	"Norminette",
	run_norminette,
	{ desc = "Run norminette and show errors in diagnostics" }
)

-- Optional: Key mapping
vim.api.nvim_set_keymap("n", "<leader>n", ":Norminette<CR>", { noremap = true, silent = true })
