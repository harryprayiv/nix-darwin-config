{
  config,
  pkgs,
  ...
}: let
  home = "${config.xdg.configHome}/nixpkgs";
  fish = "${pkgs.fish}/bin/fish";
  rg = "${pkgs.ripgrep}/bin/rg";
  xrandr = "${pkgs.xorg.xrandr}/bin/xrandr";
in
  pkgs.writeShellScriptBin "hms" ''
    monitors=$(${xrandr} --query | ${rg} '\bconnected')

    if [[ $monitors == *"HDMI"* ]]; then
      echo "Switching to HM config for uhd display"
      cd ${home}
      nix build --impure .#homeConfigurations.bismuth-uhd.activationPackage
      result/activate
      cd -
    elif [[ $monitors == *"HDMI-1"* ]]; then
      echo "Switching to HM config for HDMI-2 laptop display"
      cd ${home}
      nix build --impure .#homeConfigurations.bismuth-edp.activationPackage
      result/activate
      cd -
    elif [[ $monitors == *"HDMI-2"* ]]; then
      echo "Switching to HM config for HDMI-2 laptop display"
      cd ${home}
      nix build --impure .#homeConfigurations.bismuth-edp.activationPackage
      result/activate
      cd -
    else
      echo "Could not detect monitor: $monitors"
      exit 1
    fi

    if [[ $1 == "fish" ]]; then
      ${fish} -c fish_update_completions
    fi

    if [[ $1 == "restart" ]]; then
      echo "⚠️ Restarting X11 (requires authentication) ⚠️"
      systemctl restart display-manager
    fi
  ''
