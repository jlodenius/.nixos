return {
  {
    "xiyaowong/transparent.nvim",
    priority = 1001,
    config = function()
      local transparent = require("transparent")
      transparent.setup({
        extra_groups = {
          "NvimTreeNormal", -- NvimTree
        },
      })
      vim.cmd([[:TransparentEnable]])
    end,
  },
  {
    "savq/melange-nvim",
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme melange]])

      -- melange palette variables
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

        -- blended / UI-specific tones
        visual_bg = "#514045", -- rose + surface blend (Melange uses this vibe)
      }

      local hl = function(group, opts) vim.api.nvim_set_hl(0, group, opts) end

      hl("LineNr", {
        fg = melange.muted,
      })

      hl("CursorLineNr", {
        fg = melange.gold,
        bg = "None",
      })

      hl("Cursor", {
        bg = melange.gold,
        fg = melange.base,
      })

      hl("CursorLine", {
        bg = melange.surface,
      })

      hl("Visual", {
        bg = melange.visual_bg,
      })

      hl("MatchParen", {
        fg = melange.lavender,
        bg = melange.overlay,
        bold = true,
      })

      -- Popup background for Telescope (Melange-style panels use 'surface')
      local telescope_bg = melange.surface
      local telescope_border = melange.overlay
      local telescope_title = melange.gold -- accent highlight

      -- Border
      hl("TelescopeBorder", {
        bg = telescope_bg,
        fg = telescope_border,
      })

      -- Main window bg
      hl("TelescopeNormal", {
        bg = telescope_bg,
        fg = melange.text,
      })

      -- Title (use gold accent to mirror Melange UI headings)
      hl("TelescopeTitle", {
        bg = telescope_bg,
        fg = telescope_title,
        bold = true,
      })

      -- Nvim tree
      -- More options https://github.com/nvim-tree/nvim-tree.lua/blob/master/doc/nvim-tree-lua.txt#L1563
      hl("NvimTreeNormal", {
        bg = "None",
      })
    end,
  },
}
