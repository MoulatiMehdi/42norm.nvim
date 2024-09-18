
# nvim-norminette
<div align="center">
![Neovim](https://img.shields.io/badge/Neovim-%2301c4ff?logo=neovim&logoColor=white) ![Lua](https://img.shields.io/badge/Lua-%232c2c2c?logo=lua&logoColor=white)
</div>

A Neovim plugin that integrates Norminette linter and `c_formatter_42` for formatting C code according to 42 school norms.

## ✨ Features

- Show diagnostics inside Neovim
- Format the current buffer 
- Insert/Update 42header to your files

## 🔨 Prerequisites

- **Neovim** : Ensure Neovim is installed on your system.
- **Lua** : The plugin requires Lua to be available in Neovim.
- **Python 3.8+** : Ensure you have Python 3.8 or higher installed to run c_formatter_42.

## 📝 Note : 
the plugin will try to install these commands. if it fails please install them before using the plugin:

- [c_formatter_42](https://github.com/dawnbeen/c_formatter_42) 
- [norminette](https://github.com/42School/norminette)
## 📦 Installation
Install the plugin with your preferred package manager:

### Using `lazy.nvim`

```lua
{
    "MoulatiMehdi/nvim-norminette",
    config = function()
        local norm = require("norminette")

        norm.setup({
            header_on_save = true,
            format_on_save = true,
        })

        -- Press "F5" key to run the norminette
        vim.keymap.set("n", "<F5>", function()
            norm.check_norms()
        end, { desc = "Update 42norms diagnostics", noremap = true, silent = true })

        vim.keymap.set("n", "<C-f>", function()
            norm.format()
        end, { desc = "Format buffer on 42norms", noremap = true, silent = true })

        vim.keymap.set("n", "<F1>", function()
            norm.stdheader()
        end, { desc = "Insert 42header", noremap = true, silent = true })

        -- create your commands
        vim.api.nvim_create_user_command("Norminette", function()
            norm.check_norms()
        end, {})
        vim.api.nvim_create_user_command("Format", function()
            norm.format()
        end, {})
        vim.api.nvim_create_user_command("Stdheader", function()
            norm.stdheader()
        end, {})
    end,
}
```

### Using `packer.nvim`

```lua

use {
    "MoulatiMehdi/nvim-norminette",
    config = function()
        local norm = require("norminette")

        norm.setup({
            header_on_save = true,
            format_on_save = true,
        })
        -- Press "F5" key to run the norminette
        vim.keymap.set("n", "<F5>", function()
            norm.check_norms()
        end, { desc = "Update 42norms diagnostics", noremap = true, silent = true })

        -- Press "Ctrl + f" to format the buffer
        vim.keymap.set("n", "<C-f>", function()
            norm.format()
        end, { desc = "Format buffer on 42norms", noremap = true, silent = true })

        -- Press "F1" to add the header
        vim.keymap.set("n", "<F1>", function()
            norm.stdheader()
        end, { desc = "Insert 42header", noremap = true, silent = true })

        vim.api.nvim_create_user_command("Norminette", function()
            norm.check_norms()
        end, {})
        vim.api.nvim_create_user_command("Format", function()
            norm.format()
        end, {})
        vim.api.nvim_create_user_command("Stdheader", function()
            norm.stdheader()
        end, {})

    end,
}
```
## ⚙️ Configuration

### Setup

**nvim-norminette** is configurable. Please refer to the default settings below.

```lua
    {
        format_on_save = false, -- format the code on save
        header_on_save = false, -- insert the header on save
        timeout = 3000, -- timeout for norminette 
    }
```

## 🤝 Contributing

Feel free to submit issues or pull requests to improve the plugin.
