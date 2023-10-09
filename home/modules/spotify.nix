{
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}:
with lib; let
  cfg = config.programs.spotify;

  package = pkgs.spotify;

  ultraHDPackage = pkgs.spotify.override {deviceScaleFactor = 1.4;};
  # See: https://github.com/NixOS/nixpkgs/issues/227449
  hidpiPackage = pkgs.spotify.override {
    callPackage = p: attrs: pkgs.callPackage p (attrs // {deviceScaleFactor = 1.4;});
  };
in {
  meta.maintainers = [hm.maintainers.bismuth];

  options.programs.spotify = {
    enable = mkEnableOption "Play music from the Spotify music service.";
  };

  config = mkIf cfg.enable {
    home.packages = [
      (
        if specialArgs.ultraHD
        then ultraHDPackage
        else package
      )
    ];
  };
}
