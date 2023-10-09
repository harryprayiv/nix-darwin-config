{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  services.loki = {
    enable = false;
    configFile = ./loki-local-config.yaml;
  };
}
