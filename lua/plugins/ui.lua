return {
  {
    'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        theme = 'dracula',
        icons_enabled = true,
      },
    },
  },
  {
    'folke/which-key.nvim',
  },
  -- autoclose
  {
    'm4xshen/autoclose.nvim',
    config = function()
      require('autoclose').setup {
        options = {
          disabled_filetypes = { 'text' },
        },
      }
    end,
  },
  -- terminal
  {
    'akinsho/toggleterm.nvim',
    opts = {
      open_mapping = [[<c-\>]],
      direction = 'float',
    },
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    enabled = false,
    main = 'ibl',
    opts = {
      indent = { char = '│' },
    },
  },
  -- markdown highlight
  {
    'lukas-reineke/headlines.nvim',
    enabled = true,
    dependencies = 'nvim-treesitter/nvim-treesitter',
    config = function()
      require('headlines').setup {
        quarto = {
          query = vim.treesitter.query.parse(
            'markdown',
            [[
              (fenced_code_block) @codeblock
              ]]
          ),
          codeblock_highlight = 'CodeBlock',
          treesitter_language = 'markdown',
        },
        markdown = {
          query = vim.treesitter.query.parse(
            'markdown',
            [[
                (fenced_code_block) @codeblock
                ]]
          ),
          codeblock_highlight = 'CodeBlock',
        },
      }
    end,
  },
  -- highlight current word
  {
    'RRethy/vim-illuminate',
    enabled = true,
  },
  { -- nicer-looking tabs with close icons
    'nanozuki/tabby.nvim',
    enabled = false,
    config = function()
      require('tabby.tabline').use_preset 'tab_only'
    end,
  },
  { -- scrollbar
    'dstein64/nvim-scrollview',
    enabled = true,
    opts = {
      current_only = true,
    },
  },
}
