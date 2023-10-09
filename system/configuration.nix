{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  customFonts = pkgs.nerdfonts.override {
    fonts = [
      "JetBrainsMono"
      "Iosevka"
      "FiraMono"
      "Noto"
    ];
  };

  myfonts = pkgs.callPackage fonts/default.nix {inherit pkgs;};
in {
  imports = [
    # Window manager
    ./wm/xmonad.nix
    # Binary cache
    ./cachix.nix
  ];

  networking = {
    # Enables wireless support and openvpn via network manager.
    networkmanager = {
      enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    alacritty
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    bc # required for Cardano Guild gLiveView
    git
    # brave
    git-crypt
    gnupg
    firejail
    dnsutils
    screen
    jq
    pinentry
    srm
    gparted
    zip
  ];

  # Making fonts accessible to applications.
  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    packages = with pkgs; [
      customFonts
      font-awesome
      fira-code
      fira-code-symbols
      hasklig
      ipaexfont
      noto-fonts-cjk
      noto-fonts-emoji
      inconsolata
      myfonts.flags-world-color
      myfonts.icomoon-feather
      myfonts.cardanofont
      myfonts.monof55
    ];
  };

  programs.fish.enable = true;
  programs.zsh.enable = true;

  # Nix daemon config
  nix = {
    # Automate garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    # Flakes settings
    package = pkgs.nixUnstable;
    registry.nixpkgs.flake = inputs.nixpkgs;
    settings = {
      # Automate `nix store --optimise`
      auto-optimise-store = true;
      extra-experimental-features = ["ca-derivations"];
      experimental-features = ["nix-command" "flakes"];
      warn-dirty = false;
      # Avoid unwanted garbage collection when using nix-direnv
      keep-outputs = true;
      keep-derivations = true;
    };
  };

  system.copySystemConfiguration = true;
  system.stateVersion = "22.11"; # LEAVE AS-IS (unless fresh install)
}
