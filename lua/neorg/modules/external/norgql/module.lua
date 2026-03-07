-- claude generated
local neorg = require 'neorg.core'
local module = neorg.modules.create 'external.norgql'

module.setup = function()
  return { success = true, requires = { 'core.integrations.treesitter' } }
end

module.load = function()
  -- Fire when any .norg buffer is opened
  vim.api.nvim_create_autocmd('BufReadPost', {
    pattern = '*.norg',
    callback = function(ev)
      module.private.handle_norg_open(ev.buf)
    end,
  })
end

module.private = {
  -- Parse @document.meta block and find a norgql field
  find_norgql = function(bufnr)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local in_meta = false
    for _, line in ipairs(lines) do
      if line:match '^@document%.meta' then
        in_meta = true
      elseif line:match '^@end' then
        in_meta = false
      elseif in_meta then
        local val = line:match '^%s*norgql%s*:%s*(.+)$'
        if val then
          return vim.trim(val)
        end
      end
    end
    return nil
  end,

  -- Run the python script and open the resulting csv in a vertical split
  run_and_open = function(norgql_path)
    local script_dir = vim.fn.fnamemodify(norgql_path, ':h')
    local script = script_dir .. '/decoder.py'
    local output_file = nil

    -- Read the output filename from the norgql file
    local f = io.open(norgql_path, 'r')
    if f then
      local content = f:read '*a'
      f:close()
      output_file = content:match '"output"%s*:%s*"([^"]+)"'
    end

    if not output_file then
      vim.notify('norgql: could not find output field in ' .. norgql_path, vim.log.levels.ERROR)
      return
    end

    local csv_path = script_dir .. '/' .. output_file

    vim.notify 'norgql: running query...'

    vim.fn.jobstart({ 'python3', script, norgql_path }, {
      cwd = script_dir,
      on_exit = function(_, code)
        if code ~= 0 then
          vim.notify('norgql: python script failed with code ' .. code, vim.log.levels.ERROR)
          return
        end
        -- Open csv in a vertical split
        vim.schedule(function()
          vim.cmd('split ' .. vim.fn.fnameescape(csv_path))
        end)
      end,
      on_stderr = function(_, data)
        if data and #data > 0 then
          vim.notify('norgql: ' .. table.concat(data, '\n'), vim.log.levels.WARN)
        end
      end,
    })
  end,

  handle_norg_open = function(bufnr)
    local norgql_rel = module.private.find_norgql(bufnr)
    if not norgql_rel then
      return
    end

    local buf_path = vim.api.nvim_buf_get_name(bufnr)
    local buf_dir = vim.fn.fnamemodify(buf_path, ':h')
    local norgql_path = buf_dir .. '/' .. norgql_rel

    if vim.fn.filereadable(norgql_path) == 0 then
      vim.notify('norgql: file not found: ' .. norgql_path, vim.log.levels.ERROR)
      return
    end

    module.private.run_and_open(norgql_path)
  end,
}

return module
