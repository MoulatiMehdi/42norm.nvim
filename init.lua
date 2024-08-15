-- init.lua in the root of the norminette plugin repo
vim.opt.runtimepath:append(".")

-- Load the Norminette plugin
local Norm = require("norminette")

-- Example key mapping to run norminette manually
vim.keymap.set("n", "<F5>", function()
	Norm.norminette()
end, { noremap = true, silent = true })
