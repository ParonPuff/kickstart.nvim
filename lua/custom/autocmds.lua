local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

augroup('MyAutocmds', { clear = true })

-- neorg
autocmd('Filetype', {
  pattern = 'norg',
  group = 'MyAutocmds',
  callback = function()
    vim.keymap.set('n', '<C-n>', '<Plug>(neorg.presenter.next-page)', { buffer = true })
    vim.keymap.set('n', '<C-p>', '<Plug>(neorg.presenter.previous-page)', { buffer = true })
    vim.keymap.set('n', '<C-q>', '<Plug>(neorg.presenter.close-page)', { buffer = true })
  end,
})

autocmd('BufWinEnter', {
  group = 'MyAutocmds',
  callback = function()
    if vim.bo.filetype == 'norg' and vim.w.is_presenter then
      require('zen-mode').open()
    end
  end,
})
