return {
  {
    "saecki/crates.nvim",
    ft = { "toml" },
    event = { "BufRead Cargo.toml" },
    dependencies = {
      "hrsh7th/nvim-cmp",
    },
    config = function()
      require("crates").setup({
        completion = {
          cmp = {
            enabled = true,
          },
        },
      })
      require("cmp").setup.buffer({
        sources = { { name = "crates" } },
      })
    end,
  },
  -- Better diagnostics?
  -- {
  --   "alexpasmantier/krust.nvim",
  --   ft = "rust",
  -- },
}
