return {
  "paj.nvim",
  lazy = false,
  after = function() vim.keymap.set("x", "<leader>ae", ":PajQuery<CR>", { desc = "Query Paj about selection" }) end,
}
