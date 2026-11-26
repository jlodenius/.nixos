return {
  "paj.nvim",
  lazy = false,
  after = function()
    require("paj").setup({
      output_size = 40,
      output_position = "right",
      edit = {
        model = "openai-codex/gpt-6-luna",
        thinking = "off",
      },
    })
    vim.keymap.set("x", "<leader>aq", ":PajQuery<CR>", { desc = "Query Paj about selection" })
    vim.keymap.set("x", "<leader>ae", "<Plug>(PajEdit)", { desc = "Edit selection with Paj" })
  end,
}
