return {
  "paj.nvim",
  lazy = false,
  after = function()
    require("paj").setup({
      output_size = 30,
      output_position = "bottom",
    })
    vim.keymap.set("x", "<leader>ae", ":PajQuery<CR>", { desc = "Query Paj about selection" })
  end,
}
