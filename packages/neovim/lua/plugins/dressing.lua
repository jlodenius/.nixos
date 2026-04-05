function IsNvimTreeOpen()
  local buffers = vim.api.nvim_list_bufs()
  for _, buf in pairs(buffers) do
    local name = vim.api.nvim_buf_get_name(buf)
    if string.find(name, "NvimTree") then return true end
  end
  return false
end

return {
  "dressing.nvim",
  event = "DeferredUIEnter",
  after = function()
    require("dressing").setup({
      input = {
        enabled = true,
        get_config = function()
          if IsNvimTreeOpen() then return { enabled = false } end
        end,
      },
    })
  end,
}
