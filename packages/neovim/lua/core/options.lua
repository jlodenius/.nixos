local opt = vim.opt

-- transparent_background
vim.g.transparent_background = true

-- line number
opt.relativenumber = true
opt.number = true

-- tabs & indent
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- line wrapping
opt.wrap = false

-- x padding when jumping
opt.sidescrolloff = 15

-- search settings
opt.ignorecase = true
opt.smartcase = true

-- cursor line
opt.cursorline = true

-- appearance
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

-- backspace key
opt.backspace = "indent,eol,start"

-- split windows
opt.splitright = true
opt.splitbelow = true

-- dont highlight search
opt.hlsearch = false

-- cursor settings
vim.cmd("set guicursor=n:blinkon100,n-v-c-sm:block,i-ci-ve:ver25-Cursor,r-cr-o:hor20")

-- swap file settings
opt.swapfile = false
opt.backup = false
opt.writebackup = false

-- persist undo history
opt.undofile = true

-- for avante
opt.laststatus = 3

-- rounded borders
vim.o.winborder = "rounded"

-- display hidden characters
opt.listchars = "tab:^ ,nbsp:¬,extends:»,precedes:«,trail:•"

-- allow virtual text in diagnostics
vim.diagnostic.config({ virtual_text = true, virtual_lines = false })
