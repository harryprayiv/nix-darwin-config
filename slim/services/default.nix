let
  more = {
    services = {
      flameshot.enable = true;
    };
  };
in [
  ./dunst
  ./gpg-agent
  ./networkmanager
  ./picom
  ./polybar
  ./screenlocker
  ./redshift
  ./betterlockscreen
  ./udiskie
  more
]
