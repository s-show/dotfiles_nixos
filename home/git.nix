{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    userName = "s-show";
    userEmail = "s1shimz@gmail.com";
    delta = {
      enable = true;
      options = {
        side-by-side = true;
        syntax-theme = "GitHub";
        keep-plus-minus-markers = true;
      };
    };
    extraConfig = {
      delta = {
        navigate = true;
      };
      merge = {
        conflictStyle = "zdiff3";
      };
    };
  };

  # GitHub CLI
  programs.gh = {
    enable = true;
    extensions = with pkgs; [
      gh-markdown-preview
    ];
    settings = {
      editor = "nvim";
    };
  };
}
