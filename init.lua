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
vim.opt.clipboard = "unnamedplus"
vim.opt.conceallevel = 2
vim.opt.textwidth = 0
vim.opt.wrapmargin = 0
vim.opt.signcolumn = "no"

vim.g.mapleader = " "
local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { silent = true, desc = "Clear search highlight" })
map("n", "<leader>w", "<cmd>write<CR>", { silent = true, desc = "Write file" })
map("n", "<leader>q", "<cmd>quit<CR>", { silent = true, desc = "Quit window" })
map("n", "<leader><leader>", "<C-^>", { silent = true, desc = "Switch to previous file" })
map("i", "jk", "<Esc>", { silent = true, desc = "Leave insert mode" })

map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

map("n", "<leader>tt", function()
  vim.cmd("botright 15split | terminal")
  vim.cmd("startinsert")
end, { desc = "Open terminal" })
map("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Leave terminal mode" })

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
  {
    "justinmk/vim-sneak",
    lazy = false,
    dependencies = { { "tpope/vim-repeat", lazy = false } },
    init = function()
      -- mini.jump2d handles explicit label jumps; Sneak stays a two-character motion.
      vim.g["sneak#label"] = 0
    end,
  },
  {
    "nvim-mini/mini.jump2d",
    version = "*",
    opts = {
      mappings = { start_jumping = "" },
      allowed_windows = { current = true, not_current = false },
    },
    keys = {
      { "<leader>jl", function()
        local jump = require("mini.jump2d")
        jump.start(jump.builtin_opts.line_start)
      end, mode = { "n", "x" }, desc = "Jump to visible line start" },
      { "<leader>jw", function()
        local jump = require("mini.jump2d")
        jump.start(jump.builtin_opts.word_start)
      end, mode = { "n", "x" }, desc = "Jump to visible word start" },
    },
  },
  { "preservim/vim-markdown", ft = { "markdown" }, config = function() vim.g.vim_markdown_folding_disabled = 1 vim.g.vim_markdown_new_list_item_indent = 0 end },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    ft = { "markdown" },
    build = "cd app && npm install",
    init = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_refresh_slow = 0
    end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", ft = "markdown", desc = "Toggle Markdown preview" },
    },
  },
  {
    "mikavilpas/yazi.nvim",
    version = "*",
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim" },
    init = function()
      -- Requires the external `yazi` executable to be installed separately.
      vim.g.loaded_netrwPlugin = 1
    end,
    keys = {
      { "<leader>e", "<cmd>Yazi<CR>", desc = "Open Yazi at current file" },
      { "<leader>E", "<cmd>Yazi cwd<CR>", desc = "Open Yazi in working directory" },
      { "<C-Up>", "<cmd>Yazi toggle<CR>", desc = "Resume Yazi" },
    },
    opts = { open_for_directories = true },
  },
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
  { "rmagatti/auto-session", config = true },
  { "folke/twilight.nvim", cmd = "Twilight" },
})

require("lualine").setup({ options = { theme = "tokyonight", section_separators = "", component_separators = "" } })

require("telescope").setup({ defaults = { layout_strategy = "vertical", layout_config = { width = 0.9 } } })
vim.keymap.set("n", "<leader>f", ":Telescope find_files<CR>", { silent = true })
vim.keymap.set("n", "<leader>g", ":Telescope live_grep<CR>", { silent = true })
map("n", "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { silent = true, desc = "Search current buffer" })

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

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    -- Uncounted movement follows wrapped rows; counts still address file lines.
    map({ "n", "x" }, "j", function() return vim.v.count == 0 and "gj" or "j" end,
      { buffer = true, expr = true, silent = true, desc = "Down wrapped row (file lines with count)" })
    map({ "n", "x" }, "k", function() return vim.v.count == 0 and "gk" or "k" end,
      { buffer = true, expr = true, silent = true, desc = "Up wrapped row (file lines with count)" })
    map("n", "<leader>jt", "<cmd>Toc<CR>", { buffer = true, silent = true, desc = "Markdown table of contents" })
    vim.cmd("ZenMode")
    vim.cmd("Limelight")
  end,
})
