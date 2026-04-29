{
  programs.opencode = {
    enable = true;
    settings = {
      theme = "everforest";
      model = "moonshotai/kimi-k2.6";
      autoupdate = true;
      tui = {
        scroll_acceleration = {
          enabled = true;
        };
      };
      permission = {
        bash = {
          "rm *" = "deny";
          "git push --force*" = "deny";
          "sudo *" = "deny";
          "dd *" ="deny";
          "mkfs*" = "deny";
          "format*" = "deny";
        };
      };
    };
  };
}
