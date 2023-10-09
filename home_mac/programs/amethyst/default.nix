{
  pkgs,
  lib,
  ...
}: {
  home.file."amethyst.yml".source = ./amethyst_config.yml;
}
