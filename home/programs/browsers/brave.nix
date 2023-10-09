{
  inputs,
  pkgs,
  ...
}: let
  inherit (inputs.stable.legacyPackages.${pkgs.system});
  # baseDir = "BraveSoftware/Brave-Browser";
in {
  programs.brave = {
    enable = true;
  };
}
