{ pkgs, ... }:
{
  programs.git = {
    settings = {
      user = {
        email = "s1shimz@gmail.com";
        name = "s-show";
      };
    };
    enable = true;
    # delta = {
    #   enable = true;
    #   options = {
    #     side-by-side = true;
    #     syntax-theme = "GitHub";
    #     keep-plus-minus-markers = true;
    #   };
    # };
    settings = {
      delta = {
        navigate = true;
      };
      merge = {
        conflictStyle = "zdiff3";
      };
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
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
