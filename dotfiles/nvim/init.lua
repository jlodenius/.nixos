-- core
require("core.keymaps")
require("core.options")

-- open scratchpad
vim.api.nvim_create_user_command("Sp", "e ~/Notes/scratchpad.md", {})

-- set up lazy plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    { import = "plugins" },
    { import = "plugins.lsp" },
  },
})

-- highlight yank
vim.cmd([[
  augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.hl.on_yank{higroup="IncSearch", timeout=100}
  augroup END
]])

-- jump to last edit position on opening file
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    if vim.fn.line("'\"") > 1 and vim.fn.line("'\"") <= vim.fn.line("$") then
      -- except for in git commit messages
      -- https://stackoverflow.com/questions/31449496/vim-ignore-specifc-file-in-autocommand
      if not vim.fn.expand("%:p"):find(".git", 1, true) then vim.cmd('exe "normal! g\'\\""') end
    end
  end,
})

-- remove trailing whitespace on save
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = { "*" },
  command = [[%s/\s\+$//e]],
})

-- html hl for .mjml
vim.cmd([[
  autocmd BufNewFile,BufRead *.mjml set filetype=html
]])

-- toml hl for .snippets
vim.cmd([[
  autocmd BufNewFile,BufRead *.snippets set filetype=toml
]])

-- workaround for rust analyzer issue
-- for _, method in ipairs({ "textDocument/diagnostic", "workspace/diagnostic" }) do
--   local default_diagnostic_handler = vim.lsp.handlers[method]
--   vim.lsp.handlers[method] = function(err, result, context, config)
--     if err ~= nil and err.code == -32802 then return end
--     return default_diagnostic_handler(err, result, context, config)
--   end
-- end
