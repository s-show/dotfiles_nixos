# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, inputs, ... }:
let
  hostname =
    if pkgs.system == "x86_64-linux" then
      "desktop"
    else if pkgs.system == "aarch64-linux" then
      "zenbook"
    else
      "generic";
in
{
  networking.hostName = hostname;

  imports = [
    # include NixOS-WSL modules
    <nixos-wsl/modules>
  ];

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  # SOPS は `$XDG_CONFIG_HOME/sops/age/keys.txt` → `$HOME/.config/sops/age/keys.txt` の順番で
  # 鍵ペアを探すので、鍵ペアの保存場所を別にしている。
  # これにより、鍵ペアを GitHub にアップロードする危険性も減少する。
  sops.age.keyFile = "/home/s-show/.config/sops/age/keys.txt";
  sops.secrets.OPENROUTER_API_KEY = {
    owner = config.users.users.s-show.name;
  };
  sops.secrets.OPENAI_API_KEY = {
    owner = config.users.users.s-show.name;
  };
  sops.secrets.CEREBRAS_API_KEY = {
    owner = config.users.users.s-show.name;
  };
  sops.secrets.GEMINI_API_KEY = {
    owner = config.users.users.s-show.name;
  };
  sops.secrets.BRAVE_SEARCH_API_KEY = {
    owner = config.users.users.s-show.name;
  };
  sops.secrets.GITHUB_MCP_PAT = {
    owner = config.users.users.s-show.name;
  };


  wsl.enable = true;
  wsl.defaultUser = "nixos";
  wsl.interop.includePath = false;
  wsl.wslConf.interop.appendWindowsPath = false;

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };
  nixpkgs.config.allowUnfree = true;
  users.users.s-show = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  programs = {
    nix-ld = {
      enable = true;
    };
    git = {
      enable = true;
    };
    vim = {
      enable = true;
    };
    zsh = {
      enable = true;
    };
    starship = {
      enable = true;
    };
    ssh = {
      startAgent = true;
    };
  };

  security.sudo = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    vim
    git
  ];
  environment.localBinInPath = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

  #services.openssh.enable = true;

  # Timezone
  time.timeZone = "Asia/Tokyo";
}
