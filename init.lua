-- init.lua in the root of the norminette plugin repo
vim.opt.runtimepath:append(".")

-- Include the main plugin file if necessary
require("norminette")

-- Optionally set up any key mappings or commands
vim.api.nvim_set_keymap("n", "<F5>", ":Norminette<CR>", { noremap = true, silent = true })
