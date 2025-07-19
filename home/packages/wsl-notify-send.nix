# packages/wsl-notify-send.nix
{ pkgs, lib, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "wsl-notify-send";
  version = "v0.1.871612270";

  src = pkgs.fetchurl {
    url = "https://github.com/stuartleeks/wsl-notify-send/releases/download/${version}/wsl-notify-send_windows_amd64.zip";
    sha256 = "03hv196xsz028wgykbcyb9j5dps09sg8pmj8k754m105s1pl6cc5"; # 実際のハッシュ値に置き換えてください
  };

  nativeBuildInputs = [ pkgs.unzip ];

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp wsl-notify-send.exe $out/bin/
    chmod +x $out/bin/wsl-notify-send.exe
  '';

  meta = with lib; {
    description = "WSL replacement for notify-send";
    homepage = "https://github.com/stuartleeks/wsl-notify-send";
    platforms = platforms.linux;
  };
}
