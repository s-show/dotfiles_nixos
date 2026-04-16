{ pkgs, lib, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "kakehashi";
  version = "v0.4.1";

  src = pkgs.fetchurl {
    url = "https://github.com/atusy/kakehashi/releases/download/${version}/kakehashi-${version}-x86_64-unknown-linux-gnu.tar.gz";
    sha256 = "sha256-DFSVXRLBZ4qvNYzItnu9t2K3KxK9D2Jpppz0gae2vRo="; # 実際のハッシュ値に置き換えてください
  };

  # nativeBuildInputs = [ pkgs.tar ];

  unpackPhase = ''
    tar xfvz $src
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp kakehashi $out/bin/
    chmod +x $out/bin/kakehashi
  '';

  meta = with lib; {
    description = "kakehashi is a Tree-sitter-based language server that bridges the gap between languages, editors, and tooling.";
    homepage = "https://github.com/atusy/kakehashi";
    platforms = platforms.linux;
  };
}
