
# 42norm.nvim

![Neovim](https://img.shields.io/badge/Neovim-%2357A143?logo=neovim&logoColor=white) 
![Lua](https://img.shields.io/badge/Lua-%232C2D72?logo=lua&logoColor=white)

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
please install these commands before using the plugin:

- [c_formatter_42](https://github.com/dawnbeen/c_formatter_42) 
- [norminette](https://github.com/42School/norminette)
## 📦 Installation
Install the plugin with your preferred package manager:

### Using `lazy.nvim`

```lua
{
    "MoulatiMehdi/42norm.nvim",
    config = function()
        local norm = require("42norm")

        norm.setup({
            header_on_save = true,
            format_on_save = true,
            liner_on_change = true,
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
    "MoulatiMehdi/42norm.nvim",
    config = function()
        local norm = require("42norm")

        norm.setup({
            header_on_save = true,
            format_on_save = true,
            linter_on_change = true,
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

**42norm.nvim** is configurable. Please refer to the default settings below.

```lua
    {
        format_on_save = false, -- format the code on save
        header_on_save = false, -- insert the header on save
        linter_on_change = true, -- update diagnostic when the buffer changed (insert mode changed are ignored)
        timeout = 3000, -- timeout for norminette 
        ignore = {}, -- list of filenames to skip when running norminette
    }
```

**Globals:**
- HEADER username:  `vim.g.user42` or `USER`
- HEADER mail:      `vim.g.mail42` or `MAIL`

## 🤝 Contributing

Special thanks to all contributors for their continuous support and contributions.
Feel free to submit issues or pull requests to improve the plugin.
