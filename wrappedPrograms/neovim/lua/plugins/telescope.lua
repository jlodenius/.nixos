return {
  "telescope.nvim",
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
    { "<leader>fs", "<cmd>Telescope live_grep<CR>", desc = "Live grep" },
    { "<leader>fc", "<cmd>Telescope grep_string<CR>", desc = "Grep string" },
    { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help tags" },
    { "<leader>fr", function() require("telescope.builtin").lsp_references() end, desc = "LSP references" },
    { "<leader><space>", function() return require("telescope.builtin").oldfiles() end, desc = "Recent files" },
    { "<leader>?", function() return require("telescope.builtin").buffers() end, desc = "Find buffers" },
    {
      "<leader>/",
      function()
        require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
          winblend = 10,
          previewer = false,
        }))
      end,
      desc = "Search in current buffer",
    },
  },
  after = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      defaults = {
        path_display = { "truncate" },
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-h>"] = actions.select_horizontal,
            ["<C-v>"] = actions.select_vertical,
            ["<C-q>"] = function(bufnr)
              actions.smart_send_to_qflist(bufnr)
              actions.open_qflist(bufnr)
            end,
          },
        },
      },
    })

    pcall(telescope.load_extension, "fzf")
  end,
}
