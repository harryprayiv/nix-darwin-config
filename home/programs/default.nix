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

      zoxide = {
        enable = true;
        enableFishIntegration = true;
        options = [];
      };

      # programs with custom modules
      #megasync.enable = true;
      #discord.enable = true;
      # spotify.enable = true;
    };
  };
in [
  ./alacritty
  ./autorandr
  ./browsers/firefox.nix
  ./browsers/brave.nix
  # ./browsers/palemoon.nix
  ./cardano
  ./dconf
  ./git
  ./fish
  ./hacking-toolkit
  ./haskell
  ./neofetch
  ./neovim-ide
  ./orage
  ./purescript
  ./python
  ./rofi
  ./rust
  ./signal
  ./towerPkgs
  ./xmonad
  ./vscodium
  more
]
