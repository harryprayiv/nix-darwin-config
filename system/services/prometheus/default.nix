{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  services.prometheus = {
    enable = false;
    port = 9001;
    exporters = {
      node = {
        enable = true;
        enabledCollectors = ["systemd"];
        port = 9002;
      };
    };
  };
}
