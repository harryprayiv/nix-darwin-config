let
  more = {
    programs = {
      bat.enable = true;

      broot = {
        enable = true;
        enableFishIntegration = true;
      };

      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      fzf = {
        enable = true;
        enableFishIntegration = true;
        defaultCommand = "fd --type file --follow"; # FZF_DEFAULT_COMMAND
        defaultOptions = ["--height 20%"]; # FZF_DEFAULT_OPTS
        fileWidgetCommand = "fd --type file --follow"; # FZF_CTRL_T_COMMAND
      };

      gpg.enable = true;

      htop = {
        enable = true;
        settings = {
          sort_direction = true;
          sort_key = "PERCENT_CPU";
        };
      };

      jq.enable = true;

      obs-studio = {
        enable = false;
        plugins = [];
      };

      ssh.enable = true;

      zoxide = {
        enable = true;
        enableFishIntegration = true;
        options = [];
      };

      # programs with custom modules
      #megasync.enable = true;
      #discord.enable = true;
      spotify.enable = true;
    };
  };
in [
  ./alacritty
  ./autorandr
  ./browsers/firefox.nix
  ./browsers/brave.nix
  ./cardano
  ./dconf
  ./git
  ./fish
  ./neofetch
  ./neovim-ide
  ./orage
  ./rofi
  ./signal
  ./xmonad
  ./vscode
  ./yubikey
  more
]
