# VSCodium 扩展清单。
#
# 全部取自 open-vsx（VSCodium 的默认扩展市场），逐个固定版本与哈希，
# 由 nix 构建成 $out/share/vscode/extensions/<publisher>.<name>，
# 再经 with-extensions.nix 以 --extensions-dir 注入编辑器。
#
# 因此扩展目录是 store 里的只读目录，UI 里装不了/更新不了扩展；
# 想加扩展就往下面列表里加一条。
#
# 升级某个扩展：
#   1. 查最新版本与下载地址
#        curl -s https://open-vsx.org/api/<ns>/<name>/latest | jq '{version, download: .files.download}'
#   2. 取哈希（输出即 SRI 形式，可直接填进 hash）
#        nix store prefetch-file --json --hash-type sha256 '<files.download>'
#   3. 改下面的 version 与 hash。
{ pkgs }:
let
  inherit (pkgs.vscode-utils) buildVscodeExtension;

  # open-vsx 的下载地址形如
  #   https://open-vsx.org/api/<ns>/<name>/<ver>/file/<ns>.<name>-<ver>.vsix
  # namespace 的大小写按 open-vsx 注册的写法（GitHub、MS-CEINTL）。
  #
  # 带原生二进制的扩展（debugpy、ruff 这类）是平台特定发布，要显式给
  # targetPlatform，否则 open-vsx 返回的默认变体可能是 darwin/alpine 的。
  # 这类 vsix 的文件名带 `@<platform>`，nix 不接受 store 名里有 `@`，
  # 因此这里自己拼一个不含 @ 的 name。
  fromOpenVsx =
    {
      namespace,
      name,
      version,
      hash,
      targetPlatform ? null,
    }:
    let
      fileName =
        "${namespace}.${name}-${version}"
        + (if targetPlatform == null then "" else "-${targetPlatform}")
        + ".vsix";
      url =
        if targetPlatform == null then
          "https://open-vsx.org/api/${namespace}/${name}/${version}/file/${namespace}.${name}-${version}.vsix"
        else
          "https://open-vsx.org/api/${namespace}/${name}/${targetPlatform}/${version}/file/${namespace}.${name}-${version}@${targetPlatform}.vsix";
    in
    buildVscodeExtension {
      pname = name;
      vscodeExtPublisher = namespace;
      vscodeExtName = name;
      vscodeExtUniqueId = "${namespace}.${name}";
      inherit version;
      src = pkgs.fetchurl {
        inherit url;
        name = fileName;
        inherit hash;
      };
    };

  # rust-analyzer 要单独处理：open-vsx 那份 vsix 不带 server 二进制（官方
  # marketplace 那份才带），扩展启动时只认 <扩展目录>/server/rust-analyzer，
  # 找不到就弹 "we don't ship binaries for your platform yet"；而扩展目录在
  # store 里只读，它也下不进去。这里把 nixpkgs 的 rust-analyzer 链进去，
  # 那个 wrapper 里已经设好 RUST_SRC_PATH 指向标准库源码。
  rustAnalyzer = (fromOpenVsx {
    namespace = "rust-lang";
    name = "rust-analyzer";
    version = "0.4.3072";
    hash = "sha256-k1McVRxEDI8jxcV9ZCY84IpLgktuY8iHyH2woi1YB3g=";
  }).overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      extdir="$out/share/vscode/extensions/rust-lang.rust-analyzer"
      mkdir -p "$extdir/server"
      ln -sf ${pkgs.rust-analyzer}/bin/rust-analyzer "$extdir/server/rust-analyzer"
    '';
  });
in
[
  (fromOpenVsx {
    namespace = "GitHub";
    name = "github-vscode-theme";
    version = "6.3.5";
    hash = "sha256-qFI2pYrUkLFgDsWg/QzqfuxW+50zZgoayCxtpjmtOvQ=";
  })
  (fromOpenVsx {
    namespace = "GitHub";
    name = "vscode-github-actions";
    version = "0.32.3";
    hash = "sha256-BYRiFiyynU0iNB2RLBXc+iGUd0sekvww/LoabKPJGr0=";
  })
  # 0.164.0 起要求 VS Code ^1.137.0，而 VSCodium 上游最新 release（1.135.06055）
  # 对应的还是 1.135，装了会报「扩展与 Code 1.135.06055 不兼容」；
  # 0.162.0 是最后一个只要求 ^1.130.0 的版本。
  (fromOpenVsx {
    namespace = "GitHub";
    name = "vscode-pull-request-github";
    version = "0.162.0";
    hash = "sha256-gZ5RJ/5sIhuGjngUXXflJ2q6vEnbjieYAURw0x4vjyI=";
  })
  (fromOpenVsx {
    namespace = "MS-CEINTL";
    name = "vscode-language-pack-zh-hans";
    version = "1.131.0";
    hash = "sha256-f/ydvpgPlZQu1WdSwdbKX0CFUBOu3TTPQCV5Kb5NGJU=";
  })
  rustAnalyzer
  (fromOpenVsx {
    namespace = "tamasfe";
    name = "even-better-toml";
    version = "0.21.2";
    hash = "sha256-89xE8cVR7e85ennw+MXbQGbGpUfiELXDzsRAC/FzsAg=";
  })
  (fromOpenVsx {
    namespace = "zokugun";
    name = "cron-tasks";
    version = "0.2.1";
    hash = "sha256-nfAQzlZfUFy1DzKhp/q2WqnGnzMdPukuTa4qsqysIro=";
  })
  (fromOpenVsx {
    namespace = "zokugun";
    name = "sync-settings";
    version = "0.21.2";
    hash = "sha256-dmytAV6X6ORdHzjhhPyC7vuvovXAEBQwAVuTo7ZecbY=";
  })
  # Vim 键位：内嵌系统里 nix 装的 nvim（靠 home.sessionPath 进 GUI 会话 PATH），
  # init 走 NVIM_APPNAME=vscodium，指向本仓库的 nvim/init.lua。
  (fromOpenVsx {
    namespace = "asvetliakov";
    name = "vscode-neovim";
    version = "1.20.0";
    hash = "sha256-+A1G+3Qe2yzDslgX3ap3N03woHrqAp5Q5uj1nqVGE7k=";
  })
  # 连远程开发机。VSCodium 用不了微软官方的 Remote-SSH（那个只在微软自己的
  # 市场里，许可证不允许第三方编辑器使用），这是 Open VSX 上的社区实现，
  # 支持 VSCodium 自己的 server。首次连接时它会在远端下载 server，
  # 下载源是 github，开发机需要走代理。
  (fromOpenVsx {
    namespace = "jeanp413";
    name = "open-remote-ssh";
    version = "0.4.0";
    hash = "sha256-TPTTcgBQ6vfmKZdwWT3vp8de4s1MmZyS5Kps4Wi2Y0s=";
  })
  # Markdown 预览增强。内置的 markdown-language-features 已经能并排预览
  # （Ctrl+K V），这个补 KaTeX/Graphviz 渲染、公式、导出 HTML/PDF、幻灯片等。
  (fromOpenVsx {
    namespace = "shd101wyy";
    name = "markdown-preview-enhanced";
    version = "0.8.39";
    hash = "sha256-bRFEb6YtLFOTe9K1Y0vyfQDTgYVa6udy2CU2wz4Ht3w=";
  })
  # ---- Python / torch 学习 ----
  # Pylance 是专有的，open-vsx 上没有，语言服务用 basedpyright 代替，
  # 并在 User/settings.json 里把 python.languageServer 设为 None 免得它去找 Pylance。
  (fromOpenVsx {
    namespace = "ms-python";
    name = "python";
    version = "2026.4.0";
    hash = "sha256-Iyrq+wHwaYJP3ZLT5ijBxEK7z6HTzJRf+XB2NAuytKY=";
  })
  (fromOpenVsx {
    namespace = "ms-python";
    name = "debugpy";
    version = "2026.6.0";
    targetPlatform = "linux-x64";
    hash = "sha256-x3RK9L9yl49XkmJKccgOK2IqERhXT62jqQPXCsA9W8o=";
  })
  (fromOpenVsx {
    namespace = "ms-toolsai";
    name = "jupyter";
    version = "2025.9.1";
    hash = "sha256-EQZgZWlExKsP9ofbSIwujFnGfsEh3PCbyqVLbt2c5x8=";
  })
  (fromOpenVsx {
    namespace = "detachhead";
    name = "basedpyright";
    version = "1.40.2";
    hash = "sha256-nIewuZJxTKL5KYy36YvaYhYS8O6WEhqOd+5/zMzi81E=";
  })
  (fromOpenVsx {
    namespace = "charliermarsh";
    name = "ruff";
    version = "2026.84.0";
    targetPlatform = "linux-x64";
    hash = "sha256-rcF2hINVWsnGkOoGz/pCbUngaK9p/Wan03qSTnxB/Xs=";
  })
]
