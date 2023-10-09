{
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.nix-colors.homeManagerModule
  ];

  colorScheme = nix-colors.colorSchemes.dracula;

  programs = {
    # kitty = {
    #   enable = true;
    #   settings = {
    #     foreground = "#${config.colorScheme.colors.base05}";
    #     background = "#${config.colorScheme.colors.base00}";
    #     # ...
    #   };
    # };
    # qutebrowser = {
    #   enable = true;
    #   colors = {
    #     # Becomes either 'dark' or 'light', based on your colors!
    #     webppage.preferred_color_scheme = "${config.colorScheme.kind}";
    #     tabs.bar.bg = "#${config.colorScheme.colors.base00}";
    #     keyhint.fg = "#${config.colorScheme.colors.base05}";
    #     # ...
    #   };
    # };
  };
}
