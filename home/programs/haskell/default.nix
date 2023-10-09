{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  haskellPkgs = with pkgs.haskellPackages; [
    cabal2nix # convert cabal projects to nix
    cabal-install # package manager
    ghc # compiler
    stack
    haskell-language-server # haskell IDE (ships with ghcide)
    hoogle # documentation
    nix-tree # visualize nix dependencies
    ihaskell
    ihaskell-blaze
    pkgs.zlib
  ];

  otherPkgs = with pkgs; [
    ihp-new # Haskell web framework (the Django of Haskell)
    binutils-unwrapped # fixes the `ar` error required by cabal
  ];
in {
  home.packages = haskellPkgs ++ otherPkgs;
}
