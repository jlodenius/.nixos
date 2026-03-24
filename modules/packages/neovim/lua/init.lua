-- core
require("core.keymaps")
require("core.options")

-- open scratchpad
vim.api.nvim_create_user_command("Sp", "e ~/Notes/scratchpad.md", {})

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
vim.cmd([[autocmd BufNewFile,BufRead *.mjml set filetype=html]])

-- toml hl for .snippets
vim.cmd([[autocmd BufNewFile,BufRead *.snippets set filetype=toml]])
