-- init.lua in the root of the norminette plugin repo
vim.opt.runtimepath:append(".")

-- Load the Norminette plugin
local norm = require("norminette")

norm.setup({
	format_on_save = true,
})
-- Example key mapping to run norminette manually
vim.keymap.set("n", "<F5>", function()
	norm.norminette()
end, { noremap = true, silent = true })

vim.keymap.set("n", "<C-f>", function()
	norm.formatter()
end, { noremap = true, silent = true })
