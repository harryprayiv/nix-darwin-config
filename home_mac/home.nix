{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  username = "bismuth";
  homeDirectory = lib.mkDefault "/Users/${username}";
  configHome = "${homeDirectory}/.config";

  # specialArgs.ultraHD = false;

  defaultPkgs = with pkgs;
    [
      alacritty
      git
      aalib # make ASCI text
      any-nix-shell # fish support for nix shell
      oh-my-fish # fish shell framework
      oh-my-zsh # zsh shell framework
      niv
      # lorri # needed for direnv
      bottom # alternative to htop & ytop
      cachix # nix caching
      docker-compose # docker manager
      dive # explore docker layers
      duf # disk usage/free utility
      eza # a better `ls`
      fd # "find" for files
      glow # terminal markdown viewer
      hyperfine # command-line benchmarking tool
      jmtpfs # mount mtp devices
      killall # kill processes by name
      libnotify # notify-send command4
      ncdu # disk space info (a better du)
      ngrok # secure tunneling to localhost
      nix-index # locate packages containing certain nixpkgs
      pgcli # modern postgres client
      prettyping # a nicer ping
      ranger # terminal file explorer
      ripgrep # fast grep
      rnix-lsp # nix lsp server
      tldr # summary of a man page
      tree # display files in a tree view
      xsel # clipboard support (also for neovim)
      srm # a command-line compatible rm(1) which overwrites file content
      pinentry # a small collection of dialog programs that allow GnuPG to read

      # Work Stuff

      #  Messaging and Social Networks
      element-desktop # matrix client
      # discord              # discord app (breaks often)
      # tdesktop             # telegram messaging client
      # slack                # slack messaging client

      #  Ricing
      cmatrix # dorky terminal matrix effect
      nyancat # the famous rainbow cat!
      ponysay # for sweet Audrey
      cowsay # cowsay fortune teller with random images

      #  Security
      # rage                 # encryption tool for secrets management
      # keepassxc            # Security ##
      # gnupg                # Security ##
      # ledger-live-desktop  # Ledger Nano X Support for NixOS
      bitwarden-cli # command-line client for the password manager
      # Useful nix related tools
      cachix # adding/managing alternative binary caches hosted by Cachix
      niv # easy dependency management for nix projects
    ]
    ++ lib.optionals stdenv.isDarwin [
      cocoapods
      m-cli # useful macOS CLI commands
    ];
in {
  imports = builtins.concatMap import [
    ./programs
    ./services
    ./scripts
  ];

  home = with inputs; {
    inherit username homeDirectory;
    stateVersion = "23.11";

    packages = defaultPkgs;
    sessionVariables = {
      DISPLAY = ":0";
      # EDITOR = "nvim";
      EDITOR = "codium";
      PAGER = "less";
      CLICLOLOR = 1;
      TERMINAL = "alacritty";
      # CARDANO_NODE_SOCKET_PATH = "/var/lib/cardano-node/db-mainnet/node.socket";
    };
  };

  # https://github.com/malob/nixpkgs/blob/master/home/default.nix

  # Direnv, load and unload environment variables depending on the current directory.
  # https://direnv.net
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.direnv.enable
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Htop
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.htop.enable
  programs.htop.enable = true;
  programs.htop.settings.show_program_path = true;
}
