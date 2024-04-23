return {

  { 'numToStr/Comment.nvim', opts = {} },

  -- quarto
  {
    'quarto-dev/quarto-nvim',
    opts = {
      ft = { 'quarto' },
      lspFeatures = {
        languages = { 'r', 'pyright', 'path', 'bash', 'python', 'yaml-language-server', 'taplo' },
        codeRunner = {
          enabled = true,
          default_method = 'slime',
        },
      },
    },
    dependencies = {
      {
        'jmbuhr/otter.nvim',
        opts = {
          lspFeatures = {
            hover = {
              border = require('misc.style').border,
            },
            languages = { 'r', 'pyright', 'path', 'bash', 'python' },
            buffers = {
              set_filetype = false,
              write_to_disk = true,
            },
            handle_leading_whitespace = true,
            codeRunner = {
              enabled = true,
              default_method = 'slime',
            },
          },
        },
      },
    },
    config = function() end,
  },

  -- send code from python/r/qmd documets to a terminal or REPL
  -- like ipython, R, bash
  {
    'jpalardy/vim-slime',
    enabled = true,
    init = function()
      vim.b['quarto_is_python_chunk'] = false
      Quarto_is_in_python_chunk = function()
        require('otter.tools.functions').is_otter_language_context 'python'
      end

      vim.cmd [[
      let g:slime_dispatch_ipython_pause = 100
      function SlimeOverride_EscapeText_quarto(text)
      call v:lua.Quarto_is_in_python_chunk()
      if exists('g:slime_python_ipython') && len(split(a:text,"\n")) > 1 && b:quarto_is_python_chunk && !(exists('b:quarto_is_r_mode') && b:quarto_is_r_mode)
      return ["%cpaste -q\n", g:slime_dispatch_ipython_pause, a:text, "--", "\n"]
      else
      if exists('b:quarto_is_r_mode') && b:quarto_is_r_mode && b:quarto_is_python_chunk
      return [a:text, "\n"]
      else
      return [a:text]
      end
      end
      endfunction
      ]]

      --slime, send code to neovim terminal
      --NOTE: for some reason using neovim doesn't work!
      -- vim.g.slime_target = 'neovim'
      -- vim.g.slime_python_ipython = 1
      -- vim.g.slime_bracketed_paste = 1

      local function mark_terminal()
        vim.g.slime_last_channel = vim.b.terminal_job_id
        vim.print(vim.g.slime_last_channel)
      end

      local function set_terminal()
        vim.b.slime_config = { jobid = vim.g.slime_last_channel }
      end

      -- require('which-key').register {
      --   ['<leader>cm'] = { mark_terminal, 'mark terminal' },
      --   ['<leader>cs'] = { set_terminal, 'set terminal' },
      -- }

      --slime, send code to tmux
      vim.g.slime_target = 'tmux'
      vim.g.slime_bracketed_paste = 1
      vim.g.slime_default_config = { socket_name = 'default', target_pane = '.2' }
    end,
  },

  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      -- note: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },
    },
    config = function()
      local util = require 'lspconfig.util'
      -- Brief Aside: **What is LSP?**
      --
      -- LSP is an acronym you've probably heard, but might not understand what it is.
      --
      -- LSP stands for Language Server Protocol. It's a protocol that helps editors
      -- and language tooling communicate in a standardized fashion.
      --
      -- In general, you have a "server" which is some tool built to understand a particular
      -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc). These Language Servers
      -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
      -- processes that communicate with some "client" - in this case, Neovim!
      --
      -- LSP provides Neovim with features like:
      --  - Go to definition
      --  - Find references
      --  - Autocompletion
      --  - Symbol Search
      --  - and more!
      --
      -- Thus, Language Servers are external tools that must be installed separately from
      -- Neovim. This is where `mason` and related plugins come into play.
      --
      -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
      -- and elegantly composed help section, `:help lsp-vs-treesitter`

      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-T>.
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

          -- Find references for the word under your cursor.
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('gD', require('telescope.builtin').lsp_type_definitions, '[G]oto type [D]efinition')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

          -- Fuzzy find all the symbols in your current workspace
          --  Similar to document symbols, except searches over your whole project.
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

          -- Opens a popup that displays documentation about the word under your cursor
          --  See `:help K` for why this keymap
          map('K', vim.lsp.buf.hover, 'Hover Documentation')

          -- bind gh to go to sigature help
          -- This is useful when you're in the middle of typing a function call and you want to see
          -- the signature of the function you're calling.
          map('gh', vim.lsp.buf.signature_help, 'Signature [H]elp')

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP Specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/

      local lsp_flags = {
        allow_incremental_sync = true,
        debounce_text_changes = 150,
      }
      vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = require('misc.style').border })
      vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = require('misc.style').border })

      local servers = {

        lua_ls = {
          -- cmd = {...},
          -- filetypes { ...},
          -- capabilities = {},
          settings = {
            Lua = {
              runtime = { version = 'LuaJIT' },
              workspace = {
                checkThirdParty = false,
                -- Tells lua_ls where to find all the Lua files that you have loaded
                -- for your neovim configuration.
                library = {
                  '${3rd}/luv/library',
                  unpack(vim.api.nvim_get_runtime_file('', true)),
                },
                -- If lua_ls is really slow on your computer, you can try this instead:
                -- library = { vim.env.VIMRUNTIME },
              },
              completion = {
                callSnippet = 'Replace',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },

        pyright = {
          flags = lsp_flags,
        },

        r_language_server = {
          flags = lsp_flags,
          settings = {
            r = {
              lsp = {
                rich_documentation = false,
              },
            },
          },
        },

        bashls = {
          flags = lsp_flags,
          filetypes = { 'sh', 'zsh', 'bash' },
        },

        --awk_ls = {},
        snakefmt = {},

        html = {},

        cssls = {},

        ltex = {},

        jsonls = {},

        marksman = {
          filetypes = { 'markdown', 'quarto' },
          root_dir = util.root_pattern('.git', '.marksman.toml', '_quarto.yml'),
        },
      }

      -- Ensure the servers and tools above are installed
      --  To check the current status of installed tools and/or manually install
      --  other tools, you can run
      --    :Mason
      --
      --  You can press `g?` for help in this menu
      require('mason').setup {}

      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or { 'lua_ls' })
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format lua code
        'black',
        'isort',
        'prettier', -- Used to format javascript code
        'shfmt', -- Used to format bash code
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for tsserver)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },

  { -- Autoformat
    'stevearc/conform.nvim',
    enabled = true,
    opts = {
      notify_on_error = false,
      format_on_save = {
        timeout_ms = 2000,
        lsp_fallback = true,
      },
      lang_to_ext = {
        bash = 'sh',
        r = 'r',
        python = 'py',
        markdown = 'md',
        -- latex = 'tex',
      },
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'isort', 'black' },
        r = { 'styler' }, -- syler is slow, according to the author, so increased timeout
        -- Conform can also run multiple formatters sequentially
        -- You can use a sub-list to tell conform to run *until* a formatter
        -- is found.
        -- javascript = { { "prettierd", "prettier" } },
      },
    },
  },

  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          -- Build Step is needed for regex support in snippets
          -- This step is not supported in many windows environments
          -- Remove the below condition to re-enable on windows
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
      },
      { 'saadparwaiz1/cmp_luasnip' },

      -- Adds other completion capabilities.
      --  nvim-cmp does not ship with all sources by default. They are split
      --  into multiple repos for maintenance purposes.
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'hrsh7th/cmp-nvim-lsp-signature-help' },
      { 'hrsh7th/cmp-path' },
      -- If you want to add a bunch of pre-configured snippets,
      --    you can use this plugin to help you. It even has snippets
      --    for various frameworks/libraries/etc. but you will have to
      --    set up the ones that are useful for you.
      -- 'rafamadriz/friendly-snippets',
      { 'f3fora/cmp-spell' },
      { 'hrsh7th/cmp-emoji' },
      { 'hrsh7th/cmp-calc' },
      { 'hrsh7th/cmp-buffer' },
      { 'ray-x/cmp-treesitter' },
      { 'jmbuhr/cmp-pandoc-references' },
      { 'kdheepak/cmp-latex-symbols' },
      { 'rafamadriz/friendly-snippets' },
      { 'L3MON4D3/LuaSnip' },
      { 'onsails/lspkind-nvim' },
    },
    config = function()
      -- See `:help cmp`
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      local lspkind = require 'lspkind'

      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match '%s' == nil
      end

      luasnip.config.setup {}

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },

        -- For an understanding of why these mappings were
        -- chosen, you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        mapping = cmp.mapping.preset.insert {
          ['<C-f>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),

          -- Select the [n]ext item
          ['<C-n>'] = cmp.mapping.select_next_item(),
          -- Select the [p]revious item
          ['<C-p>'] = cmp.mapping.select_prev_item(),

          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { 'i', 's' }),

          -- Accept ([y]es) the completion.
          --  This will auto-import if your LSP supports it.
          --  This will expand snippets if the LSP sent a snippet.
          ['<C-e>'] = cmp.mapping.abort(),
          ['<C-y>'] = cmp.mapping.confirm { select = true },
          ['<CR>'] = cmp.mapping.confirm { select = true },

          -- Manually trigger a completion from nvim-cmp.
          --  Generally you don't need this, because nvim-cmp will display
          --  completions whenever it has completion options available.
          ['<C-Space>'] = cmp.mapping.complete {},

          -- Think of <c-l> as moving to the right of your snippet expansion.
          --  So if you have a snippet that's like:
          --  function $name($args)
          --    $body
          --  end
          --
          -- <c-l> will move you to the right of each of the expansion locations.
          -- <c-h> is similar, except moving you backwards.
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),
        },

        ---@diagnostic disable-next-line: missing-fields
        formatting = {
          format = lspkind.cmp_format {
            mode = 'symbol',
            menu = {
              otter = '[🦦]',
              nvim_lsp = '[LSP]',
              luasnip = '[snip]',
              buffer = '[buf]',
              path = '[path]',
              spell = '[spell]',
              pandoc_references = '[ref]',
              tags = '[tag]',
              treesitter = '[TS]',
              calc = '[calc]',
              -- latex_symbols = '[tex]',
              -- emoji = '[emoji]',
              snakefmt = '[snake]',
            },
          },
        },

        sources = {
          { name = 'lua_ls' },
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'pyright' },
          { name = 'r_language_server' },
          { name = 'bashls' },
          { name = 'otter' },
          { name = 'path' },
          { name = 'calc' },
          -- { name = 'latex_symbols' },
          -- { name = 'emoji' },
          { name = 'pandoc_references' },
          { name = 'spell' },
          { name = 'snakefmt' },
        },

        view = {
          entries = 'native',
        },
        window = {
          documentation = {
            border = require('misc.style').border,
          },
        },
      }

      -- friendly snippets
      require('luasnip.loaders.from_vscode').lazy_load()
      -- custom snippets
      require('luasnip.loaders.from_vscode').lazy_load {
        paths = {
          vim.fn.stdpath 'config' .. '/snips',
        },
      }
      -- link quarto and rmarkdown to markdown snippets
      luasnip.filetype_extend('quarto', { 'markdown' })
      luasnip.filetype_extend('rmarkdown', { 'markdown' })
    end,
  },

  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
    config = function()
      -- [[ Configure Treesitter ]] See `:help nvim-treesitter`

      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
          'r',
          'python',
          'markdown',
          'markdown_inline',
          'latex',
          'bash',
          'lua',
          'html',
          'css',
          'dot',
          'json',
          'vim',
          'vimdoc',
          'yaml',
          'toml',
          'mermaid',
          'norg',
          'javascript',
          'typescript',
        },
        -- Autoinstall languages that are not installed
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = 'gnn',
            node_incremental = 'grn',
            scope_incremental = 'grc',
            node_decremental = 'grm',
          },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
              ['al'] = '@loop.outer',
              ['il'] = '@loop.inner',
              ['ab'] = '@block.outer',
              ['ib'] = '@block.inner',
              ['aa'] = '@parameter.outer',
              ['ia'] = '@parameter.inner',
            },
          },
          move = {
            enable = true,
            -- Whether to set jumps in the jumplist
            set_jumps = true,
            goto_next_start = {
              [']m'] = '@function.outer',
              [']]'] = '@class.inner',
            },
            goto_next_end = {
              [']M'] = '@function.outer',
              [']['] = '@class.outer',
            },
            goto_previous_start = {
              ['[m'] = '@function.outer',
              ['[['] = '@class.inner',
            },
            goto_previous_end = {
              ['[M'] = '@function.outer',
              ['[]'] = '@class.outer',
            },
          },
        },
      }

      -- There are additional nvim-treesitter modules that you can use to interact
      -- with nvim-treesitter. You should go explore a few and see what interests you:
      --
      --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
      --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
      --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
    end,
  },

  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [']quote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      --local statusline = require 'mini.statusline'
      --statusline.setup()

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we disable the section for
      -- cursor information because line numbers are already enabled
      ---@diagnostic disable-next-line: duplicate-set-field
      --statusline.section_location = function()
      --  return ''
      --end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },

  -- { --github copilot
  --   'github/copilot.vim',
  -- },
  -- use this one instead
  { -- gh copilot
    'zbirenbaum/copilot.lua',
    config = function()
      require('copilot').setup {
        suggestion = {
          enabled = true,
          auto_trigger = true,
          debounce = 75,
          keymap = {
            accept = '<c-a>',
            accept_word = false,
            accept_line = false,
            next = '<M-]>',
            prev = '<M-[>',
            dismiss = '<C-]>',
          },
        },
        panel = { enabled = false },
      }
    end,
  },

  -- paste an image from the clipboard or drag-and-drop
  {
    'HakonHarnes/img-clip.nvim',
    event = 'BufEnter',
    opts = {
      filetypes = {
        markdown = {
          url_encode_path = true,
          template = '![$CURSOR]($FILE_PATH)',
          drag_and_drop = {
            download_images = false,
          },
        },
        quarto = {
          url_encode_path = true,
          template = '![$CURSOR]($FILE_PATH)',
          drag_and_drop = {
            download_images = false,
          },
        },
      },
    },
  },
  -- preview equations
  {
    'jbyuki/nabla.nvim',
    keys = {
      { '<leader>qm', ':lua require"nabla".toggle_virt()<cr>', desc = 'toggle [m]ath equations' },
    },
  },
}
