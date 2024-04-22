---@diagnostic disable: undefined-global
return {
  {
    'nvim-telescope/telescope-ui-select.nvim',
  },
  {
    'nvim-telescope/telescope-dap.nvim',
  },
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_fonts },
      { -- If encountering errors, see telescope-fzf-native README for install instructions
        'nvim-telescope/telescope-fzf-native.nvim',
        'jonarrien/telescope-cmdline.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
    config = function()
      -- Learn to use telescope by doing:
      -- :Telescope help_tags
      --
      -- Two important keymaps to use while in telescope:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      require('telescope').setup {
        defaults = {
          buffer_previewer_maker = new_maker,
          file_ignore_patterns = {
            'node_modules',
            '%_files/*.html',
            '%_cache*/',
            'docs/',
            '.git/',
            'site_libs',
            '.venv',
            '%_freeze/',
            'data/',
            'plots/',
            '.snakemake/',
            '*log*/',
            'resources/',
            'results/',
          },
          layout_strategy = 'flex',
          sorting_strategy = 'ascending',
          layout_config = {
            prompt_position = 'top',
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown {},
          },
        },
      }
      require('telescope').load_extension 'ui-select'
      require('telescope').load_extension 'dap'
      require('telescope').load_extension 'fzf'
      require('telescope').load_extension 'cmdline'
    end,
  },
}
