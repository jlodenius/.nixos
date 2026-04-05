return {
  "roslyn.nvim",
  lazy = false,
  after = function()
    require("roslyn").setup({
      broad_search = true,
      lock_target = true,
      choose_target = function(targets)
        for _, target in ipairs(targets) do
          if target:match("Linux%.sln$") then return target end
        end
        return targets[1]
      end,
    })
  end,
}
