return {
  { "vim-fugitive", lazy = false },
  {
    "gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    after = function() require("gitsigns").setup() end,
  },
  {
    "vgit-nvim",
    event = "VimEnter",
    keys = {
      { "<leader>cb", "<cmd>VGit buffer_conflict_accept_both<cr>", desc = "VGit: Accept Both" },
      { "<leader>co", "<cmd>VGit buffer_conflict_accept_current<cr>", desc = "VGit: Accept Current" },
      { "<leader>ct", "<cmd>VGit buffer_conflict_accept_incoming<cr>", desc = "VGit: Accept Incoming" },
    },
    after = function() require("vgit").setup() end,
  },
}
