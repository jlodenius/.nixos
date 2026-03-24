return {
  "nvim-treesitter",
  lazy = false,
  after = function()
    require("nvim-treesitter.configs").setup({
      highlight = { enable = true },
      indent = { enable = true },
      autotag = { enable = true },
      -- grammars provided by nix, no ensure_installed needed
      sync_install = false,
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<CR>",
          node_incremental = "<CR>",
          scope_incremental = "<S-CR>",
          node_decremental = "<BS>",
        },
      },
    })
  end,
}
