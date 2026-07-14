# 42norm.nvim

[Neovim](https://neovim.io/) plugin for integrating 42 school tooling with C and Python workflows.

## Features

- Diagnostics from Norminette and Flake8
- Buffer formatting for C files
- 42 header insertion and refresh
- Optional on-save and on-change automation

## Supported files

- **C**: [`42norm.handlers.c`](lua/42norm/handlers/c.lua)
- **Python**: [`42norm.handlers.python`](lua/42norm/handlers/python.lua)

## Requirements

- Neovim 0.9+
- `norminette`
- `flake8`
- `c_formatter_42`

Install the external tools with:

```sh
python -m pip install norminette flake8 c-formatter-42
```

## Installation

### lazy.nvim

```lua
{
  "MoulatiMehdi/42norm.nvim",
  config = function()
    require("42norm").setup({
      format_on_save = false,
      header_on_save = false,
      lint_on_change = true,
      timeout = 3000,
      ignore = {},
    })
  end,
}
```

## Configuration

Configuration is handled by [`42norm.setup`](lua/42norm/init.lua) and defaults are defined in [`lua/42norm/config.lua`](lua/42norm/config.lua).

```lua
{
  format_on_save = false,
  header_on_save = false,
  lint_on_change = true,
  timeout = 3000,
  ignore = {},
}
```

### Options

- `format_on_save`: format before saving
- `header_on_save`: update or insert the 42 header before saving
- `lint_on_change`: refresh diagnostics after buffer changes
- `timeout`: command timeout in milliseconds
- `ignore`: list of filenames to skip

## Usage

### Lua API

- [`42norm.check_norms`](lua/42norm/init.lua) — run the active file linter
- [`42norm.format`](lua/42norm/init.lua) — format the current buffer
- [`42norm.refresh_buffer`](lua/42norm/init.lua) — rerun diagnostics for the current buffer
- [`42norm.attach_to_buffer`](lua/42norm/init.lua) — attach change tracking to the current buffer
- [`42norm.header.stdheader`](lua/42norm/header/init.lua) — insert or update the 42 header

### Example keymaps

```lua
local norm = require("42norm")

vim.keymap.set("n", "<F5>", norm.check_norms, { desc = "Run diagnostics" })
vim.keymap.set("n", "<C-f>", norm.format, { desc = "Format buffer" })
vim.keymap.set("n", "<F1>", function()
  require("42norm.header").stdheader()
end, { desc = "Insert 42 header" })
```

### Example commands

```lua
vim.api.nvim_create_user_command("Norminette", function()
  require("42norm").check_norms()
end, {})

vim.api.nvim_create_user_command("Format42", function()
  require("42norm").format()
end, {})

vim.api.nvim_create_user_command("Stdheader", function()
  require("42norm.header").stdheader()
end, {})
```

## Implementation overview

- Linting logic is implemented in [`lua/42norm/linter/init.lua`](lua/42norm/linter/init.lua)
- Shared buffer and process utilities are in [`lua/42norm/utils/init.lua`](lua/42norm/utils/init.lua)
- C formatting is implemented in [`lua/42norm/formatter/init.lua`](lua/42norm/formatter/init.lua)
- Header generation is implemented in [`lua/42norm/header/init.lua`](lua/42norm/header/init.lua)
- Filetype-specific handlers are registered in [`lua/42norm/handlers/init.lua`](lua/42norm/handlers/init.lua)

## Contributing

Contributions are welcome. Please keep changes focused and consistent with the existing module layout.

