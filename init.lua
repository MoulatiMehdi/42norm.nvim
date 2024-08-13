local function run_norminette()
  -- Get the current buffer's file name
  local file = vim.fn.expand '%:p'

  -- Check if the file is valid
  if file == '' then
    print 'No file to check.'
    return
  end

  -- Run norminette command
  local handle = io.popen('norminette ' .. file)
  if not handle then
    print 'Failed to run norminette.'
    return
  end

  local output = handle:read '*a'
  handle:close()

  -- Parse the output into Neovim diagnostics
  local diagnostics = {}
  for line in output:gmatch '[^\r\n]+' do
    -- Extract line number and message (customize as needed)
    local line_number, message = line:match '(%d+):(.+)'
    if line_number and message then
      table.insert(diagnostics, {
        lnum = tonumber(line_number) - 1, -- Neovim uses 0-based indexing
        col = 0,
        severity = vim.diagnostic.severity.ERROR,
        message = message,
      })
    end
  end

  -- Set the diagnostics in the current buffer
  vim.diagnostic.set(0, 0, diagnostics) -- `0` for current buffer and namespace
end

-- Register the command
vim.api.nvim_create_user_command('Norminette', run_norminette, { desc = 'Run norminette and show errors in diagnostics' })

-- Optional: Key mapping
vim.api.nvim_set_keymap('n', '<leader>n', ':Norminette<CR>', { noremap = true, silent = true })

-- Return the plugin specification table
return {
  {
    'local/norminette', -- This is just a placeholder
    cmd = 'Norminette',
    setup = function()
      -- Optionally, you can include any setup logic here if needed
    end,
  },
}
