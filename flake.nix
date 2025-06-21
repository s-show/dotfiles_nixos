{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager/";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs =
    inputs:
    let
      # 各マシンのシステムタイプを定義する辞書
      systems = {
        desktop = "x86_64-linux";
        zenbook = "aarch64-linux";
      };

      # NixOS のシステム構成を作成するヘルパー関数（Home Manager統合版）
      mkNixosSystem =
        machine: system:
        inputs.nixpkgs.lib.nixosSystem {
          system = system;
          modules = [
            ./configuration.nix
            inputs.sops-nix.nixosModules.sops
            # Home ManagerをNixOSモジュールとして統合
            inputs.home-manager.nixosModules.home-manager
            {
              # nixpkgsにoverlayを適用
              nixpkgs.overlays = [
                inputs.neovim-nightly-overlay.overlays.default
              ];
              # Home Manager設定
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.s-show = import ./home.nix;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];
        };
    in
    {
      nixosConfigurations = builtins.listToAttrs (
        map (machine: {
          name = machine;
          value = mkNixosSystem machine (systems.${machine});
        }) (builtins.attrNames systems)
      );
    };
}
