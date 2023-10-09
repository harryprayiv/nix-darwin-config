{
  pkgs,
  lib,
  ...
}: {
  # Nix configuration ------------------------------------------------------------------------------
  nix = {
    configureBuildUsers = true;
    settings.trusted-users = [
      "@admin"
      "bismuth"
    ];
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Enable experimental nix command and flakes
  system.defaults = {
    NSGlobalDomain.InitialKeyRepeat = 14;
    NSGlobalDomain.KeyRepeat = 2;
    NSGlobalDomain.NSTableViewDefaultSizeMode = 2;
    NSGlobalDomain."com.apple.springing.delay" = 2.0;
    NSGlobalDomain.AppleShowAllExtensions = true;
    NSGlobalDomain.AppleInterfaceStyle = "Dark";

    dock.autohide = true;
    dock.autohide-time-modifier = 0.5;
    dock.tilesize = 42;

    finder.AppleShowAllExtensions = true;
    finder._FXShowPosixPathInTitle = true;
  };
  # security.sudo.configFile = ''
  #   Defaults lecture=always
  #   Defaults lecture_file=${./groot.txt}
  # '';

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs = {
    zsh.enable = true;
    fish.enable = true;
    bash.enable = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Apps
  # `home-manager` currently has issues adding them to `~/Applications`
  # Issue: https://github.com/nix-community/home-manager/issues/1341
  environment.systemPackages = with pkgs; [
    git
    zip
    pinentry
    cacert
    dnsutils
    jq
    srm
    vim
    wget
    bc
    alacritty
    terminal-notifier
  ];
  environment = {
    shells = with pkgs; [fish bash zsh];
    loginShell = pkgs.fish;
    systemPath = ["/usr/local/bin"];
    pathsToLink = ["/Applications"];
    variables = {
      # TERMINFO_DIRS = "${pkgs.kitty.terminfo.outPath}/share/terminfo";
    };
  };

  # https://github.com/nix-community/home-manager/issues/423

  programs.nix-index.enable = true;

  # Fonts
  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [
    recursive
    (nerdfonts.override {fonts = ["JetBrainsMono" "Iosevka" "FiraMono" "Noto"];})
  ];

  # fonts.packages = with pkgs; [
  #   font-awesome
  #   fira-code
  #   fira-code-symbols
  #   hasklig
  #   ipaexfont
  #   noto-fonts-cjk
  #   noto-fonts-emoji
  #   inconsolata
  #   # myfonts.flags-world-color
  #   # myfonts.icomoon-feather
  #   # myfonts.cardanofont
  #   # myfonts.monof55
  # ];
  # Keyboard
  system.keyboard.enableKeyMapping = true;
  # system.stateVersion = 4;  #not sure what this does
  homebrew = {
    enable = true;
    caskArgs.no_quarantine = true;
    global.brewfile = true;
    masApps = {};
    casks = ["raycast" "amethyst" "chrysalis"];
    ## ~/Library/Preferences/com.amethyst.Amethyst.plist for storing config?
    ## https://github.com/ianyh/Amethyst/issues/331
    ## amethyst will pickup a config file stored at ~/.amethyst.yml

    taps = ["fujiapple852/trippy"];
    brews = ["trippy"];
    extraConfig = ''
      cask "alacritty", args: { "no-quarantine": true }
    '';
  };

  users.users.bismuth = {
    home = "/Users/bismuth";
    description = "Harry Pray IV";
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3Nz[...] bismuth@intelTower"
      "ssh-rsa AIWXwwsm[...] bismuth@macbook"
    ];
  };
}
