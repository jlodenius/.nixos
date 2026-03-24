return {
  {
    "crates.nvim",
    ft = { "toml" },
    event = { "BufRead Cargo.toml" },
    after = function()
      require("crates").setup({
        lsp = {
          enabled = true,
          actions = true,
          completion = true,
          hover = true,
        },
      })
    end,
  },
}
