-- VS Code（vscode-neovim）专用的 nvim 配置。
--
-- 由 home-manager 链接到 ~/.config/vscodium/init.lua；settings 里设了
-- "vscode-neovim.NVIM_APPNAME": "vscodium"，所以 nvim 只读这份，不碰
-- ~/.config/nvim（LazyVim 那套）。
--
-- 分界：
--   * 与编辑行为有关的，对齐终端 nvim（缩进 4、搜索、剪贴板、undo、grep 等）；
--   * 界面有关的（行号、符号列、折叠、状态栏、换行、颜色）一律留给 VS Code，
--     nvim 侧不重复实现，免得两套叠在一起。

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

----------------------------------------------------------------------
-- 剪贴板
----------------------------------------------------------------------
-- 终端 nvim 那边是在 TextYankPost 里用 OSC52（见 nvim-dots/lua/config/
-- autocmds.lua），这里不能用：vscode-neovim 起的是 --embed 的 nvim，
-- 没有终端去解释 OSC 序列。
--
-- 扩展 runtime 里自带了一个走 VS Code 剪贴板 API 的 provider
-- （runtime/vscode/clipboard.lua，定义 g:vscode_clipboard，copy/paste 调
-- vscode.env.clipboard），但它只在 WSL 下自动启用，注释里也写了可以自己
-- 在 init 里覆盖 g:clipboard，这里就显式装上。这样 nvim 的 y/p 与 VS Code
-- 自己的 Ctrl+C/Ctrl+V 共用同一个剪贴板。
pcall(require, "vscode.clipboard")
if vim.g.vscode_clipboard then
    vim.g.clipboard = vim.g.vscode_clipboard
end
vim.opt.clipboard = "unnamedplus"

-- yank 后闪一下（终端配置里也做了这件事）
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank()
    end,
})

----------------------------------------------------------------------
-- 编辑行为，对齐终端 nvim
----------------------------------------------------------------------
local opt = vim.opt

-- 缩进：options.lua 里是 shiftwidth=4 / tabstop=4 / expandtab
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftround = true
opt.smartindent = true

-- 搜索
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true
opt.inccommand = "nosplit"

-- 滚动留白
opt.scrolloff = 4
opt.sidescrolloff = 8

-- undo / 响应速度
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200
opt.timeoutlen = 300
opt.confirm = true
opt.virtualedit = "block"

-- 命令行与 :grep
opt.wildmode = "longest:full,full"
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.grepprg = "rg --vimgrep"
opt.grepformat = "%f:%l:%c:%m"

vim.opt.iskeyword:append("-")

----------------------------------------------------------------------
-- 交给 VS Code 的部分（显式关掉 nvim 的，避免叠加）
----------------------------------------------------------------------
opt.number = false
opt.relativenumber = false
opt.signcolumn = "no"
opt.foldenable = false
opt.list = false
opt.cursorline = false

----------------------------------------------------------------------
-- 快捷键，对齐终端 nvim 的 keymaps.lua（Ctrl+A 全选）
----------------------------------------------------------------------
vim.keymap.set({ "n", "i", "v" }, "<C-a>", function()
    vim.api.nvim_command("normal! ggVG")
end, { desc = "Select all" })
