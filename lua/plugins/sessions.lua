return {

  {
    'rmagatti/auto-session',
    enabled = true,
    config = function()
      require('auto-session').setup {
        auto_session_suppress_dirs = {
          '~/',
          '~/Projects',
          '~/Downloads',
          'Desktop',
          '/',
        },
        session_lens = {
          buftypes_to_ignore = {},
          load_on_setup = true,
          theme_conf = { border = true },
          previewer = false,
        },
        vim.keymap.set('n', '<leader>sl', require('auto-session.session-lens').search_session, { noremap = true }),
      }
    end,
  },
}
