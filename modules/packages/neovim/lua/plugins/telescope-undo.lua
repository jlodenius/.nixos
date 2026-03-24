return {
  "telescope-undo.nvim",
  keys = {
    { "<leader>u", "<cmd>Telescope undo<cr>", desc = "undo history" },
  },
  after = function()
    require("telescope").setup({ extensions = { undo = {} } })
    require("telescope").load_extension("undo")
  end,
}
