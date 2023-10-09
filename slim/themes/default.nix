let
  themes = {pkgs, ...}: {
    gtk = {
      enable = true;
      iconTheme = {
        name = "Gruvbox";
        package = pkgs.gruvbox-dark-icons-gtk;
      };
      theme = {
        name = "Nordic";
        package = pkgs.nordic;
      };
    };
  };
in [themes]
