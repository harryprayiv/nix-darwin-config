let
  themes = {pkgs, ...}: {
    gtk = {
      enable = true;
      iconTheme = {
        name = "Gruvbox";
        package = pkgs.gruvbox-dark-icons-gtk;
      };
      theme = {
        name = "Qogir-Dark";
        package = pkgs.qogir-theme;
      };
    };
  };
in [themes]
