{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  purescriptPkgs = with pkgs; [
    purescript
    nodejs
    nodePackages.purs-tidy
    esbuild
  ];

  hsklPkgs = with pkgs.haskellPackages; [
    # purescript-bridge_0_15_0_0 #Generate PureScript data types from Haskell data types
    # yesod-purescript
    # hs2ps #translate haskell types to Purescript
    # dovetail #PureScript interpreter with a Haskell FFI
    # servant-purescript #Generate PureScript accessor functions for you servant API
  ];

  stable_purescriptPkgs = with inputs.stable.legacyPackages.x86_64-linux; [
    purenix
    spago
  ];
in {
  home.packages = purescriptPkgs ++ hsklPkgs ++ stable_purescriptPkgs;
}
