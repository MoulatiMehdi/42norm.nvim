local M = {}
local linter = require("42norm.linter")
local formatter = require("42norm.formatter")

local function on_complete(output, run_err)
    if run_err == "timeout" then
        vim.notify("linter: Timed out (check for missing ';').", vim.log.levels.ERROR)
        return
    elseif run_err then
        vim.notify(run_err, vim.log.levels.ERROR)
        return
    end

    if output == nil then
        return
    end

    local diagnostics = {}
    for line in output:gmatch("[^\r\n]+") do
        local line_number, col, message = line:match("^[^:]*:(%d+):(%d+):%s*E%d+%s*(.*)")
        if line_number then
            local severity

            severity = vim.diagnostic.severity.ERROR

            table.insert(diagnostics, {
                lnum = tonumber(line_number or "1") - 1,
                col = tonumber(col or "1") - 1,
                severity = severity,
                message = message,
            })
        end
    end

    return diagnostics
end


function M.lint()
    linter.lint("flake8", on_complete)
end

function M.format()
end

return M
