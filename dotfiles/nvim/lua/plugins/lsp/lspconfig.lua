return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
  },
  config = function()
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    -- Rust
    vim.lsp.config("rust_analyzer", {
      capabilities,
      settings = {
        ["rust-analyzer"] = {
          cargo = {
            features = "all",
          },
          checkOnSave = {
            enable = true,
          },
          check = {
            command = "clippy",
          },
          imports = {
            group = {
              enable = false,
            },
          },
          completion = {
            postfix = {
              enable = false,
            },
          },
        },
      },
    })
    vim.lsp.enable("rust_analyzer")

    -- Python
    vim.lsp.config("pyright", {
      capabilities,
    })
    vim.lsp.enable("pyright")

    -- Typescript
    vim.lsp.config("ts_ls", {
      capabilities,
    })
    vim.lsp.enable("ts_ls")

    -- Lua
    vim.lsp.config("lua_ls", {
      capabilities,
      settings = {
        Lua = {
          telemetry = { enable = false },
          diagnostics = { globals = { "vim", "bufnr" } },
          workspace = {
            checkThirdParty = false,
            library = {
              [vim.fn.expand("$VIMRUNTIME/lua")] = true,
              [vim.fn.stdpath("config") .. "/lua"] = true,
            },
          },
        },
      },
    })
    vim.lsp.enable("lua_ls")

    -- Tailwind
    vim.lsp.config("tailwindcss", {
      capabilities,
    })
    vim.lsp.enable("tailwindcss")

    -- HTML
    vim.lsp.config("html", {
      capabilities,
    })
    vim.lsp.enable("html")

    -- CSS
    vim.lsp.config("cssls", {
      capabilities,
      settings = {
        css = { lint = { unknownAtRules = "ignore" } },
      },
    })
    vim.lsp.enable("cssls")

    -- Eslint
    vim.lsp.config("eslint", {
      capabilities,
      settings = {
        workingDirectories = { mode = "auto" },
      },
    })
    vim.lsp.enable("eslint")

    -- Emmet
    vim.lsp.config("emmet_ls", {
      capabilities,
      filetypes = {
        "html",
        "typescriptreact",
        "javascriptreact",
        "css",
        "sass",
        "scss",
        "less",
        "svelte",
      },
    })
    vim.lsp.enable("emmet_ls")

    -- Nix
    vim.lsp.config("nil_ls", {
      capabilities = capabilities,
      settings = {
        ["nil"] = {
          formatting = {
            command = { "alejandra" },
          },
        },
      },
    })
    vim.lsp.enable("nil_ls")

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { noremap = true, silent = true, buffer = bufnr }

    --  Global keymaps
    vim.keymap.set("n", "åd", function() vim.diagnostic.jump({ count = 1, float = true }) end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = -1, float = true }) end, opts)

    -- Use LspAttach autocommand to only map the following keys
    -- after the language server attaches to the current buffer
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gv", ":vsplit | lua vim.lsp.buf.definition()<CR>", opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

        local client = vim.lsp.get_client_by_id(ev.data.client_id)

        -- Disable semanticTokensProvider
        -- https://www.reddit.com/r/neovim/comments/143efmd/is_it_possible_to_disable_treesitter_completely/
        client.server_capabilities.semanticTokensProvider = nil
      end,
    })
  end,
}
