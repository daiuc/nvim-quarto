--local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
--if not vim.loop.fs_stat(lazypath) then
--  vim.fn.system({
--    "git",
--    "clone",
--    "--filter=blob:none",
--    "https://github.com/folke/lazy.nvim.git",
--    "--branch=stable",
--    lazypath,
--  })
--end
--vim.opt.rtp:prepend(lazypath)

require 'config.global'
require 'config.lazy'
require 'config.autocommands'
require 'config.keymap'
require 'config.colors'

-- Use vim-plug to install vim plugins
-- using lazyvim to install plugins
--local vim = vim
-- local Plug = vim.fn['plug#']
--
-- vim.call 'plug#begin'
--
-- Plug 'raivivek/vim-snakemake'
--
-- vim.call 'plug#end'
