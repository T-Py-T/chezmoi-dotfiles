-- Export checkhealth to a file
local health_output = {}

-- Redirect output
local orig_print = print
local function capture_print(...)
  local args = {...}
  for _, v in ipairs(args) do
    table.insert(health_output, tostring(v))
  end
end

-- Run checkhealth and capture
vim.notify = function(msg) table.insert(health_output, msg) end

-- Run checkhealth
vim.cmd('redir! > /tmp/nvim_checkhealth.txt')
vim.cmd('silent checkhealth')
vim.cmd('redir END')

print("Health check exported to /tmp/nvim_checkhealth.txt")
