local M = {}
local function is_dir_in_path(dir)
	local path = vim.fn.getenv("PATH")
	return path:find(dir, 1, true) ~= nil
end

-- Function to notify the user if ~/.local/bin is not in PATH
local function check_local_bin_in_path()
	local local_bin_dir = vim.fn.expand("~/.local/bin")

	if not is_dir_in_path(local_bin_dir) then
		vim.notify(
			"Warning: ~/.local/bin is not in your PATH. Please add it to ensure tools can be found.",
			vim.log.levels.WARN
		)
		local current_path = vim.fn.getenv("PATH")
		vim.fn.setenv("PATH", local_bin_dir .. ":" .. current_path)
	end
end
-- Utility function to check if a binary exists globally
local function binary_exists(bin)
	return vim.fn.executable(bin) == 1
end

-- Function to install missing tools
local function install_if_missing(tool, install_cmd)
	if not binary_exists(tool) then
		vim.notify(tool .. " not found. Installing...", vim.log.levels.INFO)
		local handle = io.popen(install_cmd)
		if not handle then
			vim.notify(tool .. "can't run the command", vim.log.levels.INFO)
			return
		end
		local result = handle:read("*a")
		handle:close()

		-- Check if installation succeeded
		if not binary_exists(tool) then
			error("Failed to install " .. tool .. ":\n" .. result)
		else
			vim.notify(tool .. " installed successfully!", vim.log.levels.INFO)
		end
	end
end

-- Function to ensure that Norminette and c_formatter_42 are installed
function M.ensure_tools_installed()
	check_local_bin_in_path()
	-- Install Norminette if missing
	install_if_missing("norminette", "pip install --user norminette")

	-- Install c_formatter_42 if missing
	install_if_missing("c_formatter_42", "pip install --user c_formatter_42")
end

return M
