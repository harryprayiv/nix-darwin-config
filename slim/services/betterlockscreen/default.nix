{pkgs, ...}: {
  xdg.configFile."betterlockscreenrc".source = ./betterlockscreenrc;
  home.file.".betterlockscreenrc".text = ''
    set auto-load safe-path /nix/store
  '';
}
