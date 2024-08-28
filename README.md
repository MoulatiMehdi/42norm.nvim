
# nvim-norminette

![Neovim](https://img.shields.io/badge/Neovim-%2301c4ff?logo=neovim&logoColor=white) ![Lua](https://img.shields.io/badge/Lua-%232c2c2c?logo=lua&logoColor=white)

A Neovim plugin that integrates Norminette linter and `c_formatter_42` for formatting C code according to 42 school norms.

## 📦 Prerequisites

- Neovim: Ensure Neovim is installed on your system.
- Lua: The plugin requires Lua to be available in Neovim.
- Python 3.8+: Ensure you have Python 3.8 or higher installed to run c_formatter_42.
- ![c_formatter_42](https://github.com/dawnbeen/c_formatter_42): Install c_formatter_42 is installed on your system 
- ![Norminette](https://github.com/42School/norminette): Ensure Norminette is installed on your system. 
## 🚀 Installation

### Using `lazy.nvim`

Add the following to your `lazy.nvim` configuration:

```lua
{
    "MoulatiMehdi/nvim-norminette",
    config = function()
        local norminette = require("norminette")

        -- Shortcut for running Norminette linter
        vim.api.nvim_set_keymap("n", "<leader>nl", ":lua norminette.norminette()<CR>", { noremap = true, silent = true })

        -- Shortcut for running C Formatter 42
        vim.api.nvim_set_keymap("n", "<leader>nf", ":lua norminette.formatter()<CR>", { noremap = true, silent = true })
    end,
}
```

### Using `packer.nvim`
Add the following to your packer.nvim configuration:

```lua

use {
    "MoulatiMehdi/nvim-norminette",
    config = function()
        local norminette = require("norminette")

        -- Shortcut for running Norminette linter
        vim.api.nvim_set_keymap("n", "<leader>nl", ":lua norminette.norminette()<CR>", { noremap = true, silent = true })

        -- Shortcut for running C Formatter 42
        vim.api.nvim_set_keymap("n", "<leader>nf", ":lua norminette.formatter()<CR>", { noremap = true, silent = true })
    end,
}
```

## 🛠️ Usage

Running Norminette Linter

- Use the shortcut <leader>nl to run the Norminette linter on the current buffer.
Formatting C Code
- Use the shortcut <leader>nf to format the current buffer using c_formatter_42.

## 🤝 Contributing

Feel free to submit issues or pull requests to improve the plugin.
