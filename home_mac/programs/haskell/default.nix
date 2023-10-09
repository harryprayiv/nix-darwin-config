{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  haskellPkgs = with pkgs.haskellPackages; [
    # cabal2nix
    cabal-install
    ghc
    # haskell-language-server
    hoogle
    nix-tree
    hls-fourmolu-plugin
    fourmolu
    # hackage-mirror
  ];

  otherPKgs = with pkgs; [
    zlib
    ihp-new
    binutils-unwrapped
  ];
in {
  home.packages = haskellPkgs ++ otherPKgs;
}
