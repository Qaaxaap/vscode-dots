-- vscode-neovim 专用的 init。
--
-- 为什么不直接用 ~/.config/nvim（LazyVim）：vscode-neovim 默认会加载用户配置，
-- 而 LazyVim 的 statusline / bufferline / telescope / dashboard 这些 UI 插件会和
-- VS Code 自己的界面打架。这份只保留与编辑行为有关的设置。
--
-- 另一个做法是在 ~/nix/config/nvim-dots/init.lua 开头加：
--     if vim.g.vscode then return end
-- 让 LazyVim 自己跳过，就不必单独维护这份文件。

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

-- 搜索
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

-- 缩进。文件本身的缩进由 VS Code 的 editor.* 管，这里只影响 nvim 侧的编辑动作。
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2

-- 滚动留白
opt.scrolloff = 8
opt.sidescrolloff = 8

-- 响应速度
opt.updatetime = 100
opt.timeoutlen = 300

-- 行号、符号列、折叠交给 VS Code，nvim 这边关掉，免得两套重叠
opt.number = false
opt.relativenumber = false
opt.signcolumn = "no"
opt.foldenable = false

vim.opt.iskeyword:append("-")
