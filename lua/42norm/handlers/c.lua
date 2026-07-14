local M = {}
local linter = require("42norm.linter")
local formatter = require("42norm.formatter")
local utils = require("42norm.utils")

local function on_complete(output, run_err)
	output = utils.strip_color_codes(output)

	if run_err == "timeout" then
		vim.notify("Linter Timed out.", vim.log.levels.ERROR)
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

function M.lint()
	linter.lint("norminette", on_complete)
end

function M.format()
	formatter.format("c_formatter_42")
end

return M
