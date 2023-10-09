{
  config,
  lib,
  pkgs,
  stdenv,
  inputs,
  ...
}: let
  username = "vm";
  homeDirectory = "/home/${username}";
  configHome = "${homeDirectory}/.config";

  # # workaround to open a URL in a new tab in the specific firefox profile
  # work-browser = pkgs.callPackage .././programs/browsers/work.nix {};

  defaultPkgs = with pkgs; [
    aalib # make ASCI text
    any-nix-shell # fish support for nix shell
    arandr # simple GUI for xrandr
    asciinema # record the terminal
    audacious # simple music player
    binutils-unwrapped # fixes the `ar` error required by cabal
    bc # required for Cardano Guild gLiveView
    bottom # alternative to htop & ytop
    cachix # nix caching
    calibre # e-book reader
    dconf2nix # dconf (gnome) files to nix converter
    dmenu # application launcher
    docker-compose # docker manager
    dive # explore docker layers
    drawio # diagram design
    duf # disk usage/free utility
    eza # a better `ls`
    fd # "find" for files
    glow # terminal markdown viewer
    gnomecast # chromecast local files
    hyperfine # command-line benchmarking tool
    insomnia # rest client with graphql support
    jmtpfs # mount mtp devices
    killall # kill processes by name
    #libreoffice          # office suite
    libnotify # notify-send command4
    betterlockscreen # fast lockscreen based on i3lock
    ncdu # disk space info (a better du)
    nfs-utils # utilities for NFS
    ngrok # secure tunneling to localhost
    nix-index # locate packages containing certain nixpkgs
    md-toc # generate ToC in markdown files
    adoptopenjdk-bin
    obsidian # note taking/mind mapping
    pavucontrol # pulseaudio volume control
    paprefs # pulseaudio preferences
    pasystray # pulseaudio systray
    pgcli # modern postgres client
    playerctl # music player controller
    prettyping # a nicer ping
    pulsemixer # pulseaudio mixer
    ranger # terminal file explorer
    ripgrep # fast grep
    rnix-lsp # nix lsp server
    simple-scan # scanner gui
    simplescreenrecorder # screen recorder gui
    #tex2nix              # texlive expressions for documents
    tldr # summary of a man page
    tree # display files in a tree view
    ungoogled-chromium # chrome without the Goog
    xsel # clipboard support (also for neovim)
    yad # yet another dialog - fork of zenity
    xssproxy # suspends screensaver when watching a video (forward org.freedesktop.ScreenSaver calls to Xss)
    xautolock # autolock stuff
    jupyter # pyton jupyter notebooks
    lorri # needed for direnv
    ihp-new # Haskell web framework (the Django of Haskell)
    python3Packages.ipython
    srm
    pinentry

    # Work Stuff
    work-browser

    #  Messaging and Social Networks
    element-desktop # matrix client
    discord # discord app (breaks often)
    tdesktop # telegram messaging client
    slack # slack messaging client
    tootle # mastodon client

    #  Ricing
    cmatrix # dorky terminal matrix effect
    nyancat # the famous rainbow cat!
    ponysay # for sweet Audrey
    cowsay # cowsay fortune teller with random images
    pipes # pipes vis in terminal

    #  Security
    rage # encryption tool for secrets management
    keepassxc # Security ##
    gnupg # Security ##
    ledger-live-desktop # Ledger Nano X Support for NixOS
    bitwarden-cli # command-line client for the password manager
    mr
  ];

  gnomePkgs = with pkgs.gnome; [
    eog # image viewer
    evince # pdf reader
    gucharmap # gnome character map (for font creation)

    # file manager overlay
    #nautilus # file manager
    pkgs.nautilus-gtk3
    pkgs.fontforge-gtk
    #pkgs.nautilus-bin
    #pkgs.nautilus-patched
  ];

  haskellPkgs = with pkgs.haskellPackages; [
    cabal2nix # convert cabal projects to nix
    cabal-install # package manager
    ghc # compiler
    stack
    haskell-language-server # haskell IDE (ships with ghcide)
    hoogle # documentation
    nix-tree # visualize nix dependencies
    ihaskell
    ihaskell-blaze
  ];
in {
  programs.home-manager.enable = true;

  imports = builtins.concatMap import [
    ./modules
    ./programs
    ./scripts
    ./services
    ./themes
  ];

  xdg = {
    inherit configHome;
    enable = true;
  };

  home = {
    inherit username homeDirectory;
    stateVersion = "22.11";

    packages =
      defaultPkgs
      ++ gnomePkgs
      ++ haskellPkgs;

    sessionVariables = {
      DISPLAY = ":0";
      EDITOR = "nvim";
      CARDANO_NODE_SOCKET_PATH = "/var/lib/cardano-node/db-mainnet/node.socket";
    };

    pointerCursor = {
      name = "phinger-cursors";
      package = pkgs.phinger-cursors;
      size = 25;
      gtk.enable = true;
    };
  };

  # restart services on change
  systemd.user.startServices = "sd-switch";

  xsession.numlock.enable = true;

  # notifications about home-manager news
  news.display = "silent";
}
