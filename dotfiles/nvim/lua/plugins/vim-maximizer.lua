return {
  "szw/vim-maximizer",
  config = function()
    -- keymaps
    vim.keymap.set("n", "<leader>sm", ":MaximizerToggle<CR>")
  end,
}
