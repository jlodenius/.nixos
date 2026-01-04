vim.g.mapleader = " "

local keymap = vim.keymap

-- general keymaps

-- do not add deletes to register
keymap.set("n", "<leader>d", '"_d')
keymap.set("v", "<leader>d", '"_d')

-- paste and keep register
keymap.set("x", "<leader>p", '"_dP')

-- open qf list
keymap.set("n", "Q", ":copen<CR>")

-- TODO: find a keybind
-- clear cf list
-- :cexpr []

-- navigate qf list
keymap.set("n", "<leader>,", ":cprevious<CR>zz")
keymap.set("n", "<leader>.", ":cnext<CR>zz")

-- x key does not copy deleted character to register
keymap.set("n", "x", '"_x')

-- split screen commands
keymap.set("n", "<leader>sv", "<C-w>v") -- split vertically
keymap.set("n", "<leader>sh", "<C-w>s") -- split horizontally
keymap.set("n", "<leader>se", "<C-w>=") -- make split windows equal width
keymap.set("n", "<leader>sx", ":close<CR>") -- close current split window

-- resize splits
keymap.set("n", "<leader>]", "<cmd>vertical resize +10<CR>")
keymap.set("n", "<leader>[", "<cmd>vertical resize -10<CR>")

-- move highlighted
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- show code diagnostic
keymap.set("n", "<leader>cd", "<cmd>lua vim.diagnostic.open_float()<CR>")

-- center cursor after jumping vertically
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")

-- center cursor after search
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")

-- yank to system clipboard
keymap.set("n", "<leader>y", '"+y')
keymap.set("v", "<leader>y", '"+y')
keymap.set("n", "<leader>Y", '"+Y')

-- replace current word
keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- too many typos
vim.cmd(":command W w")
vim.cmd(":command Wa wa")
vim.cmd(":command WQ wq")
vim.cmd(":command Wq wq")
vim.cmd(":command Wqa wqa")
vim.cmd(":command Q q")
vim.cmd(":command QA qa")
vim.cmd(":command Qa qa")
