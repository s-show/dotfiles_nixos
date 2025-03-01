{pkgs, ...}: {
  programs.git = {
    enable = true;
    userName = "s-show";
    userEmail = "s1shimz@gmail.com";
  };

  # GitHub CLI
  programs.gh = {
    enable = true;
    extensions = with pkgs; [gh-markdown-preview]; # オススメ
    settings = {
      editor = "nvim";
    };
  };
}

