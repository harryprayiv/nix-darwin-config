let
  more = {
    services = {
      # lorri.enable = true;
    };
  };
in [
  # ../.././secrets/mac_home.nix
  ./secrets_temp
  # ./gpg-agent
  more
]
