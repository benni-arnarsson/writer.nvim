-- ==========================================
-- NeoVim Writing Environment
-- Minimal, Focused, and Beautiful
-- For Markdown, Books & Long-form Content
-- ==========================================

vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.scrolloff = 5
vim.opt.colorcolumn = ""
vim.opt.cursorline = false
vim.opt.showmode = false
vim.opt.laststatus = 2
vim.opt.showcmd = false
vim.opt.hidden = true
vim.opt.termguicolors = true
vim.opt.spell = true
vim.opt.spelllang = { 'en_us' }
vim.opt.mouse = "a"
vim.opt.conceallevel = 2
vim.opt.textwidth = 0
vim.opt.wrapmargin = 0
vim.opt.signcolumn = "no"

vim.g.mapleader = " "
vim.keymap.set("n", "<leader>w", ":w<CR>", { silent = true })
vim.keymap.set("i", "jk", "<Esc>", { silent = true })
vim.keymap.set("n", "<leader>q", ":qa<CR>", { silent = true })

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "folke/tokyonight.nvim", lazy = false, priority = 1000, config = function() vim.cmd("colorscheme tokyonight") end },
  { "ellisonleao/gruvbox.nvim", lazy = true },
  { "catppuccin/nvim", name = "catppuccin", lazy = true },
  { "folke/zen-mode.nvim", cmd = "ZenMode" },
  { "junegunn/limelight.vim", cmd = "Limelight" },
  { "preservim/vim-markdown", ft = { "markdown" }, config = function() vim.g.vim_markdown_folding_disabled = 1 vim.g.vim_markdown_new_list_item_indent = 0 end },
  { "iamcco/markdown-preview.nvim", ft = { "markdown" }, build = "cd app && npm install" },
  { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } },
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
  { "rmagatti/auto-session", config = true },
  { "epwalsh/obsidian.nvim", ft = "markdown", opts = { workspaces = {} } },
  { "folke/twilight.nvim", cmd = "Twilight" },
})

require("lualine").setup({ options = { theme = "tokyonight", section_separators = "", component_separators = "" } })
require("nvim-tree").setup({ view = { width = 30 }, renderer = { highlight_git = false, icons = { show = { git = false } } } })
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true })

require("telescope").setup({ defaults = { layout_strategy = "vertical", layout_config = { width = 0.9 } } })
vim.keymap.set("n", "<leader>f", ":Telescope find_files<CR>", { silent = true })
vim.keymap.set("n", "<leader>g", ":Telescope live_grep<CR>", { silent = true })

vim.keymap.set("n", "<leader>z", ":ZenMode<CR>:Limelight<CR>", { silent = true })

vim.api.nvim_create_user_command("WordCount", function() local wc = vim.fn.wordcount().words print("Word count: " .. wc) end, {})

vim.api.nvim_create_user_command("Theme", function(opts)
  local theme = opts.args
  if theme == "gruvbox" then
    vim.cmd("colorscheme gruvbox")
  elseif theme == "catppuccin" then
    vim.cmd("colorscheme catppuccin")
  else
    vim.cmd("colorscheme tokyonight")
  end
  print("Theme set to " .. theme)
end, { nargs = 1 })

vim.o.sessionoptions = "buffers,curdir,tabpages,winsize"
require("auto-session").setup({
  auto_save_enabled = true,
  auto_restore_enabled = true,
  auto_session_enable_last_session = true,
})

vim.opt.scrolloff = 999

vim.api.nvim_create_autocmd("VimResized", {
  callback = function()
    local width = vim.api.nvim_win_get_width(0)
    local padding = math.floor((width - 80) / 2)
    if padding > 0 then
      vim.opt.margin = 0
      vim.opt.columns = width
      vim.opt.textwidth = 0
      vim.opt.wrap = true
      vim.opt.wrapmargin = 0
      vim.opt.colorcolumn = ""
      vim.opt.scrolloff = 999
      vim.opt.foldcolumn = "0"
      vim.opt.conceallevel = 2
      vim.opt.concealcursor = "nc"
      vim.opt.list = false
      vim.opt.number = false
      vim.opt.relativenumber = false
      vim.opt.signcolumn = "no"
      vim.cmd("set winwidth=" .. tostring(width))
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.cmd("ZenMode")
    vim.cmd("Limelight")
  end,
})
