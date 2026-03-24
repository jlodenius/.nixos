return {
  {
    "transparent.nvim",
    lazy = false,
    after = function()
      require("transparent").setup({ extra_groups = { "NvimTreeNormal" } })
      vim.cmd([[:TransparentEnable]])

      -- Re-apply devicons colors after transparent clears highlights
      require("nvim-web-devicons").setup()
    end,
  },
  {
    "melange-nvim",
    lazy = false,
    after = function()
      vim.cmd([[colorscheme melange]])

      local melange = {
        base = "#292522",
        surface = "#34302c",
        overlay = "#3f3a36",
        muted = "#6c6654",
        subtle = "#8f8a7a",
        text = "#ece1d7",
        gold = "#d7c98d",
        rose = "#b38080",
        lavender = "#a79ac0",
        blue = "#8aa6c1",
        green = "#8aa387",
        visual_bg = "#514045",
      }

      local hl = function(group, opts) vim.api.nvim_set_hl(0, group, opts) end

      hl("LineNr", { fg = melange.muted })
      hl("CursorLineNr", { fg = melange.gold, bg = "None" })
      hl("Cursor", { bg = melange.gold, fg = melange.base })
      hl("CursorLine", { bg = melange.surface })
      hl("Visual", { bg = melange.visual_bg })
      hl("MatchParen", { fg = melange.lavender, bg = melange.overlay, bold = true })

      hl("TelescopeBorder", { bg = melange.surface, fg = melange.overlay })
      hl("TelescopeNormal", { bg = melange.surface, fg = melange.text })
      hl("TelescopeTitle", { bg = melange.surface, fg = melange.gold, bold = true })
      hl("NvimTreeNormal", { bg = "None" })
    end,
  },
}
