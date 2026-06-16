return {
  "nvim-treesitter",
  lazy = false,
  after = function()
    -- main branch: no module system. Grammars come from nix (withAllGrammars),
    -- so no install/ensure_installed needed — they're already on runtimepath.
    require("nvim-treesitter").setup({})

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter_setup", { clear = true }),
      callback = function(args)
        -- Highlighting is now core (vim.treesitter.start). No-op if the
        -- filetype has no parser, so guard with pcall.
        if pcall(vim.treesitter.start, args.buf) then
          -- treesitter-based indentation (experimental in main), only where a
          -- parser actually started.
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
