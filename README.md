# vscode-dots

Qaaxaap 的 VSCodium dotfiles：设置、快捷键、扩展清单，全部由 nix 声明式管理。
组织方式参考 nvim 那份（LazyVim 配置通过符号链接挂到 `~/.config/nvim`）。

仓库：`git@github.com:Qaaxaap/vscode-dots.git`
本地：`~/Projects/vscode-dots`

## 结构

```
flake.nix             导出 lib.extensions / lib.withExtensions 给调用方
extensions.nix        扩展清单：open-vsx 坐标 + 固定版本 + 哈希
with-extensions.nix   把扩展绑到调用方的 vscodium-electron 上（--extensions-dir）
User/settings.json    用户设置
User/keybindings.json 快捷键
```

## 怎么接进 home-manager

这份仓库自己不带 nixpkgs，调用方把自己的 `pkgs` 传进来。

`~/nix/flake.nix`：

```nix
inputs.vscode-dots.url = "path:/home/Qaaxaap/Projects/vscode-dots";
# 别的机器上换成 github:Qaaxaap/vscode-dots 即可（那时要 push 后才生效）

# outputs 里：
vscodium-electron-ext = vscode-dots.lib.withExtensions {
  inherit pkgs vscodium-electron;
};
```

`~/nix/modules/files.nix` 用 `config.lib.file.mkOutOfStoreSymlink` 把两个 JSON
链进去（注意要指向本地工作目录，链到 store 副本的话 UI 里改设置写不回去）：

```nix
"VSCodium/User/settings.json".source = link "${config.home.homeDirectory}/Projects/vscode-dots/User/settings.json";
"VSCodium/User/keybindings.json".source = link "${config.home.homeDirectory}/Projects/vscode-dots/User/keybindings.json";
```

只链这两个文件而不是整个 `User/` 目录：那里还有 `globalStorage/`、
`workspaceStorage/`、`History/` 等运行时数据，不该进仓库。

## 扩展

扩展全部取自 open-vsx，固定版本与哈希，由 nix 构建。接入后
`with-extensions.nix` 会给编辑器加 `--extensions-dir` 指向合并后的只读目录
（在 store 里），所以 UI 里装不了、更新不了扩展。

加扩展：往 `extensions.nix` 里加一条。升级扩展：

```sh
curl -s https://open-vsx.org/api/<ns>/<name>/latest | jq '{version, download: .files.download}'
nix store prefetch-file --json --hash-type sha256 '<上面输出的 download>'
# 把 version 与 hash 填回 extensions.nix，然后 switch
```

**选版本时要看 `engines.vscode`。** VSCodium 的 release 通常落后 VS Code 官方，
扩展的最新版可能要求更高的 `^1.13x.0`，装上后编辑器会提示「扩展与 Code xxx
不兼容」（GitHub Pull Requests 的 0.164.0 起就要 `^1.137.0`，只能停在 0.162.0）。
挑一个 engine 不高于当前 VSCodium 的上游版本号的最新版：

```sh
curl -s https://open-vsx.org/api/<ns>/<name>/latest | jq '{version, engine: .engines.vscode}'
curl -s https://open-vsx.org/api/<ns>/<name>/<version> | jq '.engines.vscode'
```

## Vim 键位

用 `asvetliakov.vscode-neovim`（见 `extensions.nix`），内嵌系统里那份 nvim。
settings 里只设一个 appname，不写任何路径：

```json
"vscode-neovim.NVIM_APPNAME": "vscodium"
```

nvim 便会读 `~/.config/vscodium/init.lua`，即本仓库的 `nvim/init.lua`
（由 home-manager 链接过去），不去碰 `~/.config/nvim` 里的 LazyVim —— 那套的
statusline / telescope / dashboard 会和 VS Code 自己的界面重复。nvim 可执行
文件靠 PATH 找，home-manager 的 `home.sessionPath` 会把 `~/.nix-profile/bin`
带进 GUI 会话。

（注意扩展读的设置名是 `neovimInitVimPaths`，不是 `neovimInitPath`；不过既然
用 NVIM_APPNAME，就不需要它了。）

## 编辑器本体

VSCodium 与 electron 不由本仓库负责。编辑器是 `~/nix/pkgs/vscodium-electron.nix`
打的（官方 RPM + nixpkgs 的 electron，不随包再带一份 electron）。升级改那个
文件里的 `version`、`url` 与 `hash`（hash 用官方 release 的 sha256，见 AUR
vscodium-electron-bin 的 `.SRCINFO`）。

## 备注

`~/.vscode-oss/extensions/` 里留着以前手动装的扩展（早期 AUR 版装的）。
切到 `--extensions-dir` 后它们不会被加载，可以删。
