-- VS Code（vscode-neovim）专用的 nvim 配置。
--
-- 由 home-manager 链接到 ~/.config/vscodium/init.lua；vscode-neovim 在
-- User/settings.json 里设了 "vscode-neovim.NVIM_APPNAME": "vscodium"，
-- 于是 nvim 只读这份，不碰 ~/.config/nvim（LazyVim 那套）。
-- 这样做的原因：LazyVim 的 statusline / telescope / dashboard 会和 VS Code
-- 自己的界面重复，而 nvim 那份配置是给终端 nvim 用的，不该为 VS Code 改。

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

-- 搜索
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

-- 缩进。文件本身的缩进由 VS Code 的 editor.* 决定，这里只影响 nvim 侧动作。
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

-- 界面交给 VS Code，关掉 nvim 这几处，免得两套叠在一起
opt.number = false
opt.relativenumber = false
opt.signcolumn = "no"
opt.foldenable = false

vim.opt.iskeyword:append("-")
