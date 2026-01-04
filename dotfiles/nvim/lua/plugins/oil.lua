return {
  "stevearc/oil.nvim",
  opts = {},
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local oil = require("oil")
    vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
    oil.setup({
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<C-v>"] = "actions.select_vsplit",
        ["<C-x>"] = "actions.select_split",
        ["<C-t>"] = "actions.select_tab",
        ["-"] = "actions.parent",
        ["g."] = "actions.toggle_hidden",
      },
    })
  end,
}
