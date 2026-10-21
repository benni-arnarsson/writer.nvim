local M = {}
local last_root

-- Search and file marks share a root, including books outside Git. Special
-- picker/terminal buffers keep the source buffer's root.
function M.root()
    if vim.bo.buftype ~= '' then
        return last_root or vim.uv.cwd()
    end
    local path = vim.api.nvim_buf_get_name(0)
    local start = path ~= '' and path or vim.uv.cwd()
    local stat = vim.uv.fs_stat(start)
    if not stat or stat.type ~= 'directory' then
        start = vim.fs.dirname(start)
    end
    last_root = vim.fs.root(start, '.git')
        or vim.fs.root(start, 'metadata.yaml')
        or vim.uv.cwd()
    return last_root
end

function M.setup()
    vim.opt.ignorecase = true
    vim.opt.smartcase = true
    vim.opt.undofile = true
    local undo = vim.fn.stdpath('state') .. '/undo'
    vim.fn.mkdir(undo, 'p')
    vim.opt.undodir = undo .. '//'

    local actions = require('telescope.actions')
    require('telescope').setup({
        defaults = {
            layout_strategy = 'vertical',
            layout_config = { width = 0.9 },
            mappings = { i = {
                ['<Esc>'] = actions.close,
                ['<C-j>'] = actions.move_selection_next,
                ['<C-k>'] = actions.move_selection_previous,
            } },
        },
        pickers = {
            find_files = { hidden = true, find_command = { 'rg', '--files', '--hidden', '-g', '!.git' } },
            live_grep = { additional_args = { '--hidden', '--glob', '!.git/*' } },
            grep_string = { additional_args = { '--hidden', '--glob', '!.git/*' } },
        },
    })
    require('grapple').setup({
        scope = 'writing',
        icons = false,
        scopes = { {
            name = 'writing',
            desc = 'Git repository, book, or working directory',
            cache = { event = { 'BufEnter', 'DirChanged' } },
            resolver = function()
                local root = M.root()
                return root, root
            end,
        } },
    })
    require('which-key').setup({
        delay = 350,
        spec = {
            { '<leader>f', group = 'find' },
            { '<leader>j', group = 'jump' },
            { '<leader>m', group = 'Markdown' },
            { '<leader>t', group = 'terminal' },
        },
    })
    local jump = require('mini.jump2d')
    jump.setup({
        mappings = { start_jumping = '' },
        allowed_windows = { current = true, not_current = false },
    })

    local map = vim.keymap.set
    local builtin = require('telescope.builtin')
    local function project_picker(name)
        return function() builtin[name]({ cwd = M.root() }) end
    end
    map('n', '<leader>ff', project_picker('find_files'), { desc = 'Find project files' })
    map('n', '<leader>fg', project_picker('live_grep'), { desc = 'Search project text' })
    map('n', '<leader>fw', project_picker('grep_string'), { desc = 'Search word under cursor' })
    map('n', '<leader>fr', project_picker('oldfiles'), { desc = 'Find recent project files' })
    map('n', '<leader>fb', function()
        builtin.buffers({ sort_mru = true, ignore_current_buffer = true })
    end, { desc = 'Find buffers' })
    map('n', '<leader>f/', builtin.current_buffer_fuzzy_find, { desc = 'Search current file' })
    map('n', '<leader>/', builtin.current_buffer_fuzzy_find, { desc = 'Search current file' })
    map({ 'n', 'x' }, '<leader>jl', function()
        jump.start(jump.builtin_opts.line_start)
    end, { desc = 'Jump to visible line start' })
    map({ 'n', 'x' }, '<leader>jw', function()
        jump.start(jump.builtin_opts.word_start)
    end, { desc = 'Jump to visible word start' })
    map('n', '<leader>f.', builtin.resume, { desc = 'Resume previous search' })
    map('n', '<leader>fh', builtin.help_tags, { desc = 'Search help' })
    map('n', '<leader>fc', builtin.commands, { desc = 'Search commands' })
    map('n', '<leader>fa', '<cmd>Grapple toggle<CR>', { desc = 'Toggle file mark' })
    map('n', '<leader>fm', '<cmd>Grapple toggle_tags<CR>', { desc = 'Browse marked files' })
    for i = 1, 4 do
        map('n', '<leader>' .. i, '<cmd>Grapple select index=' .. i .. '<CR>', { desc = 'Marked file ' .. i })
    end

    local group = vim.api.nvim_create_augroup('WriterKeyboard', { clear = true })
    vim.api.nvim_create_autocmd('FileType', {
        group = group,
        pattern = 'markdown',
        callback = function(args)
            vim.bo[args.buf].textwidth = 0
            map('n', '<leader>jt', '<cmd>Toc<CR>', {
                buffer = args.buf, silent = true, desc = 'Markdown table of contents',
            })
            for _, key in ipairs({ 'j', 'k' }) do
                map({ 'n', 'x' }, key, function()
                    return vim.v.count == 0 and 'g' .. key or key
                end, { buffer = args.buf, expr = true, desc = 'Move through wrapped prose' })
            end
        end,
    })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter', 'FileType' }, {
        group = group,
        callback = function()
            if vim.bo.buftype ~= '' then return end
            M.root()
            local prose = vim.bo.filetype == 'markdown'
            vim.wo.spell = prose
            vim.wo.wrap = prose
            vim.wo.linebreak = prose
            vim.wo.breakindent = prose
            vim.wo.conceallevel = prose and 2 or 0
        end,
    })
end

return M
