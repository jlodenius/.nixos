return {
  {
    "mini.ai",
    lazy = false,
    after = function() require("mini.ai").setup({ n_lines = 500 }) end,
  },
  {
    "mini.surround",
    lazy = false,
    after = function()
      require("mini.surround").setup({
        custom_surroundings = {
          ["("] = { input = { "%b()", "^.().*().$" }, output = { left = "(", right = ")" } },
          ["["] = { input = { "%b[]", "^.().*().$" }, output = { left = "[", right = "]" } },
          ["{"] = { input = { "%b{}", "^.().*().$" }, output = { left = "{", right = "}" } },
          ["<"] = { input = { "%b<>", "^.().*().$" }, output = { left = "<", right = ">" } },
        },
        highlight_duration = 500,
        mappings = {
          add = "sa",
          delete = "sd",
          find = "sf",
          find_left = "sF",
          highlight = "sh",
          replace = "sr",
          update_n_lines = "sn",
          suffix_last = "l",
          suffix_next = "n",
        },
        n_lines = 20,
        respect_selection_type = false,
        search_method = "cover",
        silent = false,
      })
    end,
  },
}
