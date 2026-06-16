return {
  -- Replaces the old nvim-treesitter `autotag` module, removed in the main
  -- branch rewrite. Standalone plugin, works off core treesitter.
  "nvim-ts-autotag",
  lazy = false,
  after = function()
    require("nvim-ts-autotag").setup()
  end,
}
