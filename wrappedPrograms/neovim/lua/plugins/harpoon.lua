return {
  "harpoon2",
  lazy = false,
  after = function()
    local harpoon = require("harpoon")
    harpoon.setup({
      settings = {
        save_on_toggle = true,
        sync_on_ui_close = true,
        key = function() return vim.loop.cwd() end,
      },
    })

    vim.keymap.set("n", "<leader>H", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
    vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, { desc = "Add harpoon mark" })
    vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end)
    vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end)
    vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end)
    vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end)
  end,
}
