local M = {}

local function strip_color_codes(text)
	return text:gsub("\027%[%d+m", ""):gsub("\027%[%d);%dm", ""):gsub("\027%[%d;%d;%dm", "")
end

function M.handle_c(output, run_err)
	output = strip_color_codes(output)

	if run_err == "timeout" then
		vim.notify("Norminette: Timed out (check for missing ';').", vim.log.levels.ERROR)
		return
	elseif run_err then
		vim.notify(run_err, vim.log.levels.ERROR)
		return
	end

	if output == nil then
		return
	end

	local diagnostics = {}
	output = output:gsub("^\n?[^\n]+[\n]?", "")
	for line in output:gmatch("[^\r\n]+") do
		local trim_str = line:gsub("^%s*", "")
		local line_number, col, message = trim_str:match("line:%s*(%d+),%s*col:%s*(%d+)%):%s*(.*)")
		if line_number then
			local severity
			if line:match("^Notice:") then
				severity = vim.diagnostic.severity.WARN
			else
				severity = vim.diagnostic.severity.ERROR
			end
			table.insert(diagnostics, {
				lnum = tonumber(line_number or "1") - 1,
				col = tonumber(col or "1") - 1,
				severity = severity,
				message = message or trim_str,
			})
		end
	end

	return diagnostics
end

return M
