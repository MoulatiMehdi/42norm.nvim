local linter = require("norminette.linter")
local formatter = require("norminette.formatter")

-- Autocommand to attach Norminette to buffers of type .c and .h
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = { "*.c", "*.h" },
	callback = function()
		linter.attach_to_buffer()
	end,
	desc = "Attach Norminette to buffer on BufEnter",
})

-- Autocommand to run Norminette when exiting insert mode
vim.api.nvim_create_autocmd({ "InsertLeave", "BufEnter" }, {
	pattern = { "*.c", "*.h" },
	callback = function()
		linter.norminette()
	end,
	desc = "Run Norminette on buffer when exiting insert mode",
})

-- User command to manually run Norminette on the whole file
vim.api.nvim_create_user_command("Norminette", function()
	linter.norminette()
end, { desc = "Run Norminette on the whole file" })

-- User command to manually format the current buffer
vim.api.nvim_create_user_command("Format", function()
	formatter.formatter()
end, { desc = "Format the current buffer using 42 norms" })

-- Return the norminette and formatter functions for customization
return {
	norminette = linter.norminette,
	formatter = formatter.formatter,
}
