return {
  {
    "nvim-telescope/telescope-ui-select.nvim",
  },
  {
    "nvim-telescope/telescope-dap.nvim",
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
          },
          fzf = {
            fuzzy = true, -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true, -- override the file sorter
            case_mode = 'smart_case', -- or "ignore_case" or "respect_case"
          },
        },
      })
      --local builtin = require("telescope.builtin")
      --vim.keymap.set("n", "<C-p>", builtin.find_files, {})
      --vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})

      require("telescope").load_extension("ui-select")
      require("telescope").load_extension("dap")
    end,
  },
}
