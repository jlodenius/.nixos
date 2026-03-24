return {
  "vim-maximizer",
  lazy = false,
  after = function() vim.keymap.set("n", "<leader>sm", ":MaximizerToggle<CR>") end,
}
