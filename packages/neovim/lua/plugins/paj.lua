return {
  "paj.nvim",
  lazy = false,
  after = function()
    require("paj").setup({
      output_size = 40,
      output_position = "right",
    })
    vim.keymap.set("x", "<leader>ae", ":PajQuery<CR>", { desc = "Query Paj about selection" })
  end,
}
