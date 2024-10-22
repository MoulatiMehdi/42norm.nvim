local M = {}

local function is_python_package_installed(package_name)
	-- Execute pip command to check if the package is installed
	local handle = io.popen("python3 -m pip3 show " .. package_name .. " 2>/dev/null")

	if not handle then
		vim.notify(package .. "can't run the command", vim.log.levels.WARN)
		return nil
	end
	local result = handle:read("*a")
	handle:close()

	-- If result is empty, the package is not installed
	if result == "" then
		return false
	else
		return true
	end
end

-- Function to install missing tools
local function install_if_missing(package, install_cmd)
	if not is_python_package_installed(package) then
		vim.notify(package .. " not found. Installing...", vim.log.levels.INFO)
		local handle = io.popen(install_cmd)
		if not handle then
			vim.notify(package .. "can't run the command", vim.log.levels.WARN)
			return
		end
		local result = handle:read("*a")
		handle:close()

		-- Check if installation succeeded
		if not is_python_package_installed(package) then
			error("Failed to install " .. package .. ":\n" .. result)
		else
			vim.notify(package .. " installed successfully!", vim.log.levels.INFO)
		end
	end
end

-- Function to ensure that Norminette and c_formatter_42 are installed
function M.ensure_tools_installed()
	-- Install Norminette if missing
	install_if_missing("norminette", "python3 -m pip install --user norminette")

	-- Install c_formatter_42 if missing
	install_if_missing("c_formatter_42", "python3 -m pip install --user c_formatter_42")
end

return M
