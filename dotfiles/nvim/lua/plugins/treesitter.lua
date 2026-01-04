return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  config = function()
    local configs = require("nvim-treesitter.configs")

    configs.setup({
      highlight = { enable = true },
      indent = { enable = true },
      autotag = { enable = true },
      ensure_installed = {
        "rust",
        "json",
        "javascript",
        "typescript",
        "tsx",
        "yaml",
        "html",
        "css",
        "markdown",
        "graphql",
        "bash",
        "lua",
        "vim",
        "vimdoc",
        "dockerfile",
        "gitignore",
        "svelte",
        "python",
      },
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
