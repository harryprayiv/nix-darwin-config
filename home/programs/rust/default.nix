{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  rustPkgs = with pkgs; [
    rustc
    cargo
    rustfmt
    rust-analyzer
    clippy
    pkg-config
  ];
in {
  home.packages = rustPkgs;
}
