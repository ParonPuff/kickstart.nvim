return {
  'nvim-neorg/neorg',
  external_module_paths = {
    vim.fn.stdpath 'config' .. './../../neorg_modules/',
  },
  lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
  ft = 'norg',
  opts = {
    load = {
      ['core.defaults'] = {},
      ['core.concealer'] = {},

      ['core.dirman'] = {
        config = {
          workspaces = {
            notes = '~/neorg',
          },
          default_workspace = 'notes',
        },
      },

      ['core.qol.todo_items'] = {},

      ['core.summary'] = {},
      ['core.looking-glass'] = {},
      ['core.tangle'] = {},
      ['external.norgql'] = {},
    },
  },
}
