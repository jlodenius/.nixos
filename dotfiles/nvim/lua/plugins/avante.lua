return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  lazy = false,
  version = false,

  opts = {
    --- Provider selection
    provider = "claude",
    auto_suggestions_provider = "claude",

    --- NEW SCHEMA: all providers must live here
    providers = {
      claude = {
        endpoint = "https://api.anthropic.com",
        model = "claude-3-7-sonnet-20250219",
        disable_tools = true,
        extra_request_body = {
          temperature = 0,
          max_tokens = 4096,
        },
      },

      --- If you ever use openai/azure/gemini you put them here:
      -- openai = { ... }
      -- gemini = { ... }
      -- copilot = { ... }
    },

    --- Dual Boost (unchanged, but must reference provider names)
    dual_boost = {
      enabled = false,
      first_provider = "openai",
      second_provider = "claude",
      prompt = "Based on the two reference outputs below, generate a response that incorporates elements from both but reflects your own judgment and unique perspective. Do not provide any explanation, just give the response directly. Reference Output 1: [{{provider1_output}}], Reference Output 2: [{{provider2_output}}]",
      timeout = 60000,
    },

    behaviour = {
      auto_suggestions = false,
      auto_set_highlight_group = true,
      auto_set_keymaps = true,
      auto_apply_diff_after_generation = false,
      support_paste_from_clipboard = false,
      minimize_diff = true,
      enable_token_counting = true,
    },

    mappings = {
      diff = {
        ours = "co",
        theirs = "ct",
        all_theirs = "ca",
        both = "cb",
        cursor = "cc",
        next = "]x",
        prev = "[x",
      },
      suggestion = {
        accept = "<M-l>",
        next = "<M-]>",
        prev = "<M-[>",
        dismiss = "<C-]>",
      },
      jump = {
        next = "]]",
        prev = "[[",
      },
      submit = {
        normal = "<CR>",
        insert = "<C-s>",
      },
      sidebar = {
        apply_all = "A",
        apply_cursor = "a",
        switch_windows = "<Tab>",
        reverse_switch_windows = "<S-Tab>",
      },
    },

    hints = { enabled = true },

    windows = {
      position = "right",
      wrap = true,
      width = 30,
      sidebar_header = {
        enabled = false,
        align = "center",
        rounded = true,
      },
      input = {
        prefix = "> ",
        height = 8,
      },
      edit = {
        border = "rounded",
        start_insert = true,
      },
      ask = {
        floating = false,
        start_insert = true,
        border = "rounded",
        focus_on_apply = "ours",
      },
    },

    highlights = {
      diff = {
        current = "DiffText",
        incoming = "DiffAdd",
      },
    },

    diff = {
      autojump = true,
      list_opener = "copen",
      override_timeoutlen = 500,
    },

    suggestion = {
      debounce = 600,
      throttle = 600,
    },
  },

  build = "make",

  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
    {
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        latex = { enabled = false },
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}
