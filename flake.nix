{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager/";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
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

      # NixOS のシステム構成を作成するヘルパー関数
      mkNixosSystem =
        machine: system:
        inputs.nixpkgs.lib.nixosSystem {
          system = system;
          modules = [
            ./configuration.nix
            inputs.sops-nix.nixosModules.sops
          ];
        };

      # Home Manager のホーム構成を作成するヘルパー関数
      mkHomeManager =
        machine: system:
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = import inputs.nixpkgs {
            system = system;
            config = {
              allowUnfree = true;
            };
          };
          extraSpecialArgs = { inherit inputs; };
          modules = [
            ./home.nix
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
      homeConfigurations = builtins.listToAttrs (
        map (machine: {
          name = "s-show@" + machine;
          value = mkHomeManager machine (systems.${machine});
        }) (builtins.attrNames systems)
      );
      home-manager.sharedModules = [
        inputs.sops-nix.homeManagerModules.sops
      ];
    };
}
