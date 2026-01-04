return {
  "tpope/vim-fugitive",
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = true,
  },
  {
    -- TODO: fix this one, or replace
    -- it doesn't load unless manually running GitConflictRefresh
    "akinsho/git-conflict.nvim",
    version = "*",
    config = true,
  },
}
