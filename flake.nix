{
  description = "Qaaxaap's VSCodium dotfiles: settings/keybindings + declarative extension set";

  outputs = { self }: {
    # 自己不自带 nixpkgs：调用方（~/nix）把自己的 pkgs 传进来，
    # 这样扩展与编辑器用的是同一份 nixpkgs，也避免重复求值。
    lib = {
      # 传入调用方的 pkgs，返回扩展 derivation 列表。
      extensions = pkgs: pkgs.callPackage ./extensions.nix { };

      # 传入调用方的 pkgs 与自建的 vscodium-electron，返回加了
      # --extensions-dir 的包装（做法同 nixpkgs 的 vscode-with-extensions）。
      withExtensions =
        { pkgs, vscodium-electron }:
        pkgs.callPackage ./with-extensions.nix {
          inherit vscodium-electron;
          extensions = pkgs.callPackage ./extensions.nix { };
        };
    };
  };
}
