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
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').setup {
        defaults = {
          buffer_previewer_maker = new_maker,
          file_ignore_patterns = {
            'node_modules',
            '%_files/*.html',
            '%_cache',
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
          fzf = {
            fuzzy = true, -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true, -- override the file sorter
            case_mode = 'smart_case', -- or "ignore_case" or "respect_case"
          },
        },
      }
      --local builtin = require("telescope.builtin")
      --vim.keymap.set("n", "<C-p>", builtin.find_files, {})
      --vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})

      require('telescope').load_extension 'ui-select'
      require('telescope').load_extension 'dap'
    end,
  },
}
