{pkgs, ...}: let
  xrandr = "${pkgs.xorg.xrandr}/bin/xrandr";
in
  pkgs.writeShellScriptBin "monitor" ''
    monitors=$(${xrandr} --listmonitors)

    if [[ $monitors == *"HDMI-1"* ]]; then
      echo "HDMI-1"
    elif [[ $monitors == *"HDMI-2"* ]]; then
      echo "HDMI-2"
    elif [[ $monitors == *"HDMI-A-0"* ]]; then
      echo "HDMI-A-0"
    elif [[ $monitors == *"HDMI-2-1"* ]]; then
      echo "HDMI-2-1"
    else
      echo "HDMI-2"
    fi
  ''
