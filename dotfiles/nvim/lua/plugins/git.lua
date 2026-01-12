return {
  "tpope/vim-fugitive",
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = true,
  },
  {
    "tanvirtin/vgit.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
    -- Lazy loading on 'VimEnter' event is necessary.
    event = "VimEnter",
    keys = {
      { "<leader>cb", "<cmd>VGit buffer_conflict_accept_both<cr>", desc = "VGit: Accept Both" },
      { "<leader>co", "<cmd>VGit buffer_conflict_accept_current<cr>", desc = "VGit: Accept Current" },
      { "<leader>ct", "<cmd>VGit buffer_conflict_accept_incoming<cr>", desc = "VGit: Accept Incoming" },
    },
    config = function() require("vgit").setup() end,
  },
}
