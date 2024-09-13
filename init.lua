-- init.lua in the root of the norminette plugin repo
vim.opt.runtimepath:append(".")

-- Load the Norminette plugin
local norm = require("norminette")

norm.setup({})
-- Example key mapping to run norminette manually
vim.keymap.set("n", "<F5>", function()
	norm.check_norms()
end, { desc = "Update 42norms diagnostics", noremap = true, silent = true })

vim.keymap.set("n", "<C-f>", function()
	norm.format()
end, { desc = "Format buffer on 42norms", noremap = true, silent = true })

-- User command to manually run Norminette on the whole file
vim.api.nvim_create_user_command("Norminette", function()
	norm.check_norms()
end, { desc = "Update 42norms diagnostics" })

-- User command to manually format the current buffer
vim.api.nvim_create_user_command("Format", function()
	norm.format()
end, { desc = "Format buffer on 42norms" })
