return {
  "nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  after = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      javascript = { "eslint_d" },
      typescript = { "eslint_d" },
      javascriptreact = { "eslint_d" },
      typescriptreact = { "eslint_d" },
      svelte = { "eslint_d" },
      vue = { "eslint_d" },
      python = { "ruff" },
      nix = { "statix" },
      css = { "stylelint" },
    }
    lint.linters.stylelint.args = function()
      local config_file = vim.fn.findfile(".stylelintrc", ".;")
      if config_file == "" then return { "--disable" } end
      return {}
    end
    lint.linters.eslint_d.args = {
      "--format",
      "json",
      "--stdin",
      "--stdin-filename",
      function() return vim.api.nvim_buf_get_name(0) end,
    }

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function() lint.try_lint() end,
    })

    vim.keymap.set("n", "<leader>L", function() lint.try_lint() end, { desc = "Trigger linting for current file" })
  end,
}
