return {
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require('lualine').setup({
        options = {
          theme = 'dracula'
        }
      })
    end
  },
  {
    "folke/which-key.nvim"
  },
  -- autoclose
  {
    "m4xshen/autoclose.nvim",
    config = function ()
      require("autoclose").setup({
        options = {
          disabled_filetypes = { "text", "markdown" }
        }
      })
    end
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
    enabled = false,
    dependencies = 'nvim-treesitter/nvim-treesitter',
    config = function()
      require('headlines').setup({
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
      })
    end
  },
  -- highlight current word
  {
    'RRethy/vim-illuminate',
    enabled = false,
  },

}
