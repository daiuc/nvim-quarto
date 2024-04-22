local wk = require 'which-key'

vim.b['quarto_is_r_mode'] = nil
vim.b['reticulate_running'] = false

P = function(x)
  print(vim.inspect(x))
  return x
end

RELOAD = function(...)
  return require('plenary.reload').reload_module(...)
end

R = function(name)
  RELOAD(name)
  return require(name)
end

local nmap = function(key, effect)
  vim.keymap.set('n', key, effect, { silent = true, noremap = true })
end

local vmap = function(key, effect)
  vim.keymap.set('v', key, effect, { silent = true, noremap = true })
end

local imap = function(key, effect)
  vim.keymap.set('i', key, effect, { silent = true, noremap = true })
end

-- save with ctrl+s
imap('<C-s>', '<esc>:update<cr><esc>')
nmap('<C-s>', '<cmd>:update<cr><esc>')

-- Move between windows using <ctrl> direction
nmap('<C-j>', '<C-W>j')
nmap('<C-k>', '<C-W>k')
nmap('<C-h>', '<C-W>h')
nmap('<C-l>', '<C-W>l')

-- Resize window using <shift> arrow keys
nmap('<S-Up>', '<cmd>resize +2<CR>')
nmap('<S-Down>', '<cmd>resize -2<CR>')
nmap('<S-Left>', '<cmd>vertical resize -2<CR>')
nmap('<S-Right>', '<cmd>vertical resize +2<CR>')

-- Telescope cmdline
nmap('<leader><leader>', '<cmd>Telescope cmdline<cr>')

-- Add undo break-points
imap(',', ',<c-g>u')
imap('.', '.<c-g>u')
imap(';', ';<c-g>u')

nmap('Q', '<Nop>')

local function send_cell()
  if vim.b['quarto_is_r_mode'] == nil then
    vim.cmd [[call slime#send_cell()]]
    return
  end
  if vim.b['quarto_is_r_mode'] == true then
    vim.g.slime_python_ipython = 0
    local is_python = require('otter.tools.functions').is_otter_language_context 'python'
    if is_python and not vim.b['reticulate_running'] then
      vim.cmd [[call slime#send("reticulate::repl_python()" . "\r")]]
      vim.b['reticulate_running'] = true
    end
    if not is_python and vim.b['reticulate_running'] then
      vim.cmd [[call slime#send("exit" . "\r")]]
      vim.b['reticulate_running'] = false
    end
    vim.cmd [[call slime#send_cell()]]
  end
end

-- send code with ctrl+Enter
-- just like in e.g. RStudio
-- needs kitty (or other terminal) config:
-- map shift+enter send_text all \x1b[13;2u
-- map ctrl+enter send_text all \x1b[13;5u
nmap('<c-cr>', send_cell)
nmap('<s-cr>', send_cell)
imap('<c-cr>', send_cell)
imap('<s-cr>', send_cell)

-- send code with Enter and leader Enter
vmap('<cr>', '<Plug>SlimeRegionSend')
nmap('<leader><cr>', '<Plug>SlimeSendCell')

local function show_table()
  local node = vim.treesitter.get_node { ignore_injections = false }
  local text = vim.treesitter.get_node_text(node, 0)
  local cmd = [[call slime#send("DT::datatable(]] .. text .. [[)" . "\r")]]
  vim.cmd(cmd)
end

-- might not use what you think should be your default web browser
-- because it is a plain html file, not a link
-- see https://askubuntu.com/a/864698 for places to look for
vim.keymap.set('n', '<leader>rt', show_table, { desc = '[r] show [t]able' })

-- keep selection after indent/dedent
vmap('>', '>gv')
vmap('<', '<gv')

-- remove search highlight on esc
nmap('<esc>', '<cmd>noh<cr>')

-- find files with telescope
nmap('<c-p>', '<cmd>Telescope find_files<cr>')

-- paste and without overwriting register
vmap('<leader>p', '"_dP')

-- delete and without overwriting register
vmap('<leader>d', '"_d')

-- center after search and jumps
nmap('n', 'nzz')
nmap('<c-d>', '<c-d>zz')
nmap('<c-u>', '<c-u>zz')

-- move between splits and tabs
nmap('<c-h>', '<c-w>h')
nmap('<c-l>', '<c-w>l')
nmap('<c-j>', '<c-w>j')
nmap('<c-k>', '<c-w>k')
nmap('H', '<cmd>tabprevious<cr>')
nmap('L', '<cmd>tabnext<cr>')

local function toggle_light_dark_theme()
  if vim.o.background == 'light' then
    vim.o.background = 'dark'
    vim.cmd [[Catppuccin mocha]]
  else
    vim.o.background = 'light'
    vim.cmd [[Catppuccin latte]]
  end
end

--show kepbindings with whichkey
--add your own here if you want them to
--show up in the popup as well

-- NOTE: normal mode with <leader>
wk.register({
  n = { ':ASToggle<cr>', 'toggle autosave' },
  r = { name = 'R' },
  c = {
    name = '[c]ode / [c]ell / [c]hunk',
    c = { ':SlimeConfig<cr>', 'slime config' },
    n = { ':split term://$SHELL<cr>', 'new sh terminal' },
    v = { ':vsplit term://$SHELL<cr>', 'new sh terminal - [v]split' },
    r = {
      function()
        vim.b['quarto_is_r_mode'] = true
        vim.cmd 'split term://R'
      end,
      'new [r] terminal',
    },
    --WARN: radian is problematic, because bracketed paste mode is not supported in slime
    --So multipline brackets are not pasted correctly.
    --d = { ':split term://radian<cr>', 'new ra[d]ian terminal' },
    p = { ':split term://python<cr>', 'new [p]ython terminal' },
    i = { ':split term://ipython<cr>', 'new [i]python terminal' },
    o = {
      name = '[o]pen code chunk',
      o = { 'o# %%<cr>', 'new code chunk below' },
      p = { 'o```{python}<cr>```<esc>O', 'python code chunk' },
      r = { 'o```{r}<cr>```<esc>O', 'r code chunk' },
      b = { 'o```{bash}<cr>```<esc>O', 'bash code chunk' },
    },
    --j = { ':split term://julia<cr>', 'new julia terminal' },
    --['oo'] = { 'o# %%<cr>', 'new code chunk below' },
    --['Oo'] = { 'O# %%<cr>', 'new code chunk above' },
    --['ob'] = { 'o```{bash}<cr>```<esc>O', 'bash code chunk' },
    --['or'] = { 'o```{r}<cr>```<esc>O', 'r code chunk' },
    --['op'] = { 'o```{python}<cr>```<esc>O', 'python code chunk' },
    --['oj'] = { 'o```{julia}<cr>```<esc>O', 'julia code chunk' },
    --['ol'] = { 'o```{julia}<cr>```<esc>O', 'julia code chunk' },
  },
  i = {
    name = 'insert',
    i = { ':PasteImage<cr>', 'image from clipboard' },
  },
  v = {
    name = 'vim',
    t = { toggle_light_dark_theme, 'switch theme' },
    c = { ':Telescope colorscheme<cr>', 'colortheme' },
    l = { ':Lazy<cr>', 'Lazy' },
    m = { ':Mason<cr>', 'Mason' },
    s = { ':e $MYVIMRC | :cd %:p:h | split . | wincmd k<cr>', 'Settings' },
    h = { ':execute "h " . expand("<cword>")<cr>', 'help' },
  },
  l = {
    name = 'language/lsp',
    r = { '<cmd>Telescope lsp_references<cr>', 'references' },
    R = { vim.lsp.buf.rename, 'rename variable under cusor in buffer' },
    f = { vim.lsp.buf.format, 'format in buffer' },
    D = { vim.lsp.buf.type_definition, 'type definition' },
    a = { vim.lsp.buf.code_action, 'coda action' },
    p = { vim.diagnostic.goto_prev, 'Go to [p]revious diagnostic' },
    n = { vim.diagnostic.goto_next, 'Go to [n]ext diagnostic' },
    e = { vim.diagnostic.open_float, 'diagnostic [e]rror messages' },
    q = { vim.diagnostic.setloclist, 'diagnostic [q]uickfix list' },
    d = {
      name = 'enable/disable diagnostics',
      d = { vim.diagnostic.disable, 'disable' },
      e = { vim.diagnostic.enable, 'enable' },
    },
    g = { ':Neogen<cr>', 'neogen docstring' },
    s = { '<cmd>Telescope lsp_dynamic_workspace_symbols<cr>', 'lsp workspace [s]ymbols' },
    l = { vim.lsp.codelens.run, 'lsp code [l]ens' },

    --s = { ':ls!<cr>', 'list all buffers' },
  },
  o = {
    name = 'otter & code',
    a = { require('otter').dev_setup, 'otter activate' },
    ['o'] = { 'o# %%<cr>', 'new code chunk below' },
    ['O'] = { 'O# %%<cr>', 'new code chunk above' },
    ['b'] = { 'o```{bash}<cr>```<esc>O', 'bash code chunk' },
    ['r'] = { 'o```{r}<cr>```<esc>O', 'r code chunk' },
    ['p'] = { 'o```{python}<cr>```<esc>O', 'python code chunk' },
    ['j'] = { 'o```{julia}<cr>```<esc>O', 'julia code chunk' },
    ['l'] = { 'o```{julia}<cr>```<esc>O', 'julia code chunk' },
  },
  q = {
    name = 'quarto',
    a = { ':QuartoActivate<cr>', 'activate' },
    p = { ":lua require'quarto'.quartoPreview()<cr>", 'preview' },
    q = { ":lua require'quarto'.quartoClosePreview()<cr>", 'close' },
    h = { ':QuartoHelp ', 'help' },
    r = {
      name = 'run',
      r = { ':QuartoSendAbove<cr>', 'to cursor' },
      a = { ':QuartoSendAll<cr>', 'all' },
    },
    e = { ":lua require'otter'.export()<cr>", 'export' },
    E = { ":lua require'otter'.export(true)<cr>", 'export overwrite' },
  },
  f = {
    name = 'find (telescope)',
    f = { '<cmd>Telescope find_files<cr>', 'files' },
    h = { '<cmd>Telescope help_tags<cr>', 'help' },
    k = { '<cmd>Telescope keymaps<cr>', '[k]eymaps' },
    r = { '<cmd>Telescope lsp_references<cr>', 'lsp [r]eferences' },
    g = { '<cmd>Telescope live_grep<cr>', 'grep' },
    b = { '<cmd>Telescope current_buffer_fuzzy_find<cr>', 'fuzzy' },
    m = { '<cmd>Telescope marks<cr>', 'marks' },
    M = { '<cmd>Telescope man_pages<cr>', 'man pages' },
    c = { '<cmd>Telescope git_commits<cr>', 'git commits' },
    s = { '<cmd>Telescope lsp_document_symbols<cr>', 'lsp document symbols' },
    d = { '<cmd>Telescope diagnostics<cr>', 'search [d]iagnostics' },
    u = { '<cmd>Telescope buffers<cr>', 'b[u]ffers' },
    q = { '<cmd>Telescope quickfix<cr>', 'quickfix' },
    l = { '<cmd>Telescope loclist<cr>', 'loclist' },
    j = { '<cmd>Telescope jumplist<cr>', 'marks' },
    p = { 'project' },
  },
  h = {
    name = 'help/debug/conceal',
    c = {
      name = 'conceal',
      h = { ':set conceallevel=1<cr>', 'hide/conceal' },
      s = { ':set conceallevel=0<cr>', 'show/unconceal' },
    },
    t = {
      name = 'treesitter',
      t = { vim.treesitter.inspect_tree, 'show tree' },
      c = { ':=vim.treesitter.get_captures_at_cursor()<cr>', 'show capture' },
      n = { ':=vim.treesitter.get_node():type()<cr>', 'show node' },
    },
  },
  s = {
    name = 'spellcheck/session',
    s = { '<cmd>Telescope spell_suggest<cr>', 'spelling' },
    ['/'] = { '<cmd>setlocal spell!<cr>', 'spellcheck' },
    n = { ']s', 'next' },
    p = { '[s', 'previous' },
    g = { 'zg', 'good' },
    r = { 'zg', 'rigth' },
    w = { 'zw', 'wrong' },
    b = { 'zw', 'bad' },
    l = { 'list session' },
    d = { ':Autosession delete<cr>', 'delete session' },
    ['?'] = { '<cmd>Telescope spell_suggest<cr>', 'suggest' },
  },
  g = {
    name = 'ChatGPT',
    c = { '<cmd>ChatGPT<CR>', 'ChatGPT' },
    e = { '<cmd>ChatGPTEditWithInstruction<CR>', 'Edit with instruction', mode = { 'n', 'v' } },
    g = { '<cmd>ChatGPTRun grammar_correction<CR>', 'Grammar Correction', mode = { 'n', 'v' } },
    t = { '<cmd>ChatGPTRun translate<CR>', 'Translate', mode = { 'n', 'v' } },
    k = { '<cmd>ChatGPTRun keywords<CR>', 'Keywords', mode = { 'n', 'v' } },
    d = { '<cmd>ChatGPTRun docstring<CR>', 'Docstring', mode = { 'n', 'v' } },
    a = { '<cmd>ChatGPTRun add_tests<CR>', 'Add Tests', mode = { 'n', 'v' } },
    o = { '<cmd>ChatGPTRun optimize_code<CR>', 'Optimize Code', mode = { 'n', 'v' } },
    s = { '<cmd>ChatGPTRun summarize<CR>', 'Summarize', mode = { 'n', 'v' } },
    f = { '<cmd>ChatGPTRun fix_bugs<CR>', 'Fix Bugs', mode = { 'n', 'v' } },
    x = { '<cmd>ChatGPTRun explain_code<CR>', 'Explain Code', mode = { 'n', 'v' } },
    r = { '<cmd>ChatGPTRun roxygen_edit<CR>', 'Roxygen Edit', mode = { 'n', 'v' } },
    l = { '<cmd>ChatGPTRun code_readability_analysis<CR>', 'Code Readability Analysis', mode = { 'n', 'v' } },
  },
  --g = {
  --  name = 'git',
  --  c = { ':GitConflictRefresh<cr>', 'conflict' },
  --  g = { ':Neogit<cr>', 'neogit' },
  --  s = { ':Gitsigns<cr>', 'gitsigns' },
  --  pl = { ':Octo pr list<cr>', 'gh pr list' },
  --  pr = { ':Octo review start<cr>', 'gh pr review' },
  --  wc = { ":lua require('telescope').extensions.git_worktree.create_git_worktree()<cr>", 'worktree create' },
  --  ws = { ":lua require('telescope').extensions.git_worktree.git_worktrees()<cr>", 'worktree switch' },
  --  d = {
  --    name = 'diff',
  --    o = { ':DiffviewOpen<cr>', 'open' },
  --    c = { ':DiffviewClose<cr>', 'close' },
  --  },
  --  b = {
  --    name = 'blame',
  --    b = { ':GitBlameToggle<cr>', 'toggle' },
  --    o = { ':GitBlameOpenCommitURL<cr>', 'open' },
  --    c = { ':GitBlameCopyCommitURL<cr>', 'copy' },
  --  },
  --},
  w = {
    name = 'write',
    w = { ':w<cr>', 'write' },
  },
  x = {
    name = 'execute',
    x = { ':w<cr>:source %<cr>', 'file' },
  },
}, { mode = 'n', prefix = '<leader>' })

local is_code_chunk = function()
  local current, range = require('otter.keeper').get_current_language_context()
  if current then
    return true
  else
    return false
  end
end

local insert_code_chunk = function(lang)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>', true, false, true), 'n', true)
  local keys
  if is_code_chunk() then
    keys = [[o```<cr><cr>```{]] .. lang .. [[}<esc>o]]
  else
    keys = [[o```{]] .. lang .. [[}<cr>```<esc>O]]
  end
  keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
  vim.api.nvim_feedkeys(keys, 'n', false)
end

local insert_r_chunk = function()
  insert_code_chunk 'r'
end

local insert_py_chunk = function()
  insert_code_chunk 'python'
end

-- NOTE: normal mode
wk.register({
  ['<c-LeftMouse>'] = { '<cmd>lua vim.lsp.buf.definition()<CR>', 'go to definition' },
  ['<c-q>'] = { '<cmd>q<cr>', 'close buffer' },
  ['<esc>'] = { '<cmd>noh<cr>', 'remove search highlight' },
  ['n'] = { 'nzzzv', 'center search' },
  ['gN'] = { 'Nzzzv', 'center search' },
  ['gl'] = { '<c-]>', 'open help link' },
  ['gf'] = { ':e <cfile><CR>', 'edit file' },
  ['<m-i>'] = { insert_r_chunk, 'r code chunk' },
  ['<cm-i>'] = { insert_py_chunk, 'python code chunk' },
  ['<m-I>'] = { insert_py_chunk, 'python code chunk' },
  [']q'] = { ':silent cnext<cr>', 'quickfix next' },
  ['[q'] = { ':silent cprev<cr>', 'quickfix prev' },
  ['z?'] = { ':setlocal spell!<cr>', 'toggle spellcheck' },
}, { mode = 'n', silent = true })

-- NOTE: visual mode
wk.register({
  ['<cr>'] = { '<Plug>SlimeRegionSend', 'run code region' },
  ['<M-j>'] = { ":m'>+<cr>`<my`>mzgv`yo`z", 'move line down' },
  ['<M-k>'] = { ":m'<-2<cr>`>my`<mzgv`yo`z", 'move line up' },
  ['.'] = { ':norm .<cr>', 'repat last normal mode command' },
  ['q'] = { ':norm @q<cr>', 'repat q macro' },
}, { mode = 'v' })

-- NOTE: visual mode with <leader>
wk.register({
  ['<leader>'] = { '<Plug>SlimeRegionSend', 'run code region' },
  ['p'] = { '"_dP', 'replace without overwriting reg' },
}, { mode = 'v', prefix = '<leader>' })

-- NOTE: mode
wk.register({
  -- ['<c-e>'] = { "<esc>:FeMaco<cr>i", "edit code" },

  -- NOTE: requires macos_option_as_alt left (or both) to be set <m--> is then option+- on macOS
  ['<m-->'] = { ' <- ', 'assign' },

  --NOTE:Shift+Command+m binding below works for kitty only
  --For iTerm2, just map Shift+Option+m to Send text " %>% ".
  --Alternatively, use <Sm-m> to beind Shift+Option+m,
  --then in iTem2, map Shift+Option+m to Send Escape M (capital M)
  --and in kitty, no need to map any keys, except setting macos_option_as_alt.
  ['<S-D-m>'] = { ' %>% ', 'pipe' },

  ['<m-i>'] = { insert_r_chunk, 'r code chunk' },
  ['<cm-i>'] = { insert_py_chunk, 'python code chunk' },
  ['<m-I>'] = { insert_py_chunk, 'python code chunk' },
  ['<c-x><c-x>'] = { '<c-x><c-o>', 'omnifunc completion' },
}, { mode = 'i' })
