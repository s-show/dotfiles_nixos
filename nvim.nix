{ nixpkgs, pkgs, ... }:
{
  with import <nixpkgs> { };
  wrapNeovimUnstable pkgs.neovim-unwrapped {
    wrapperArgs = [
      "--suffix"
      "LD_LIBRARY_PATH"
      ":"
      "${stdenv.cc.cc.lib}/lib"
    ];
  }
}
