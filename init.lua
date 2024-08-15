-- init.lua in the root of the norminette plugin repo
vim.opt.runtimepath:append(".")

-- Load the Norminette plugin
local Norminette = require("norminette")

-- Optionally, set up autocommands
vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
	pattern = { "*.c", "*.h" },
	callback = function()
		Norminette.norminette()
	end,
	desc = "show Norminette errors on file save, and file open",
})

-- Optionally, create a command to manually run Norminette
vim.api.nvim_create_user_command(
	"Norminette",
	Norminette.norminette,
	{ desc = "show Norminette errors in diagnostics" }
)

-- Example key mapping to run norminette manually
vim.keymap.set("n", "<F5>", function()
	Norminette.norminette()
end, { noremap = true, silent = true })
