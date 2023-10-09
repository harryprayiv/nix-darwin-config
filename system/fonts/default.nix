{pkgs, ...}: {
  flags-world-color = pkgs.callPackage ./flags-world-color.nix {};
  icomoon-feather = pkgs.callPackage ./icomoon-feather.nix {};
  cardanofont = pkgs.callPackage ./cardanofont.nix {};
  monof55 = pkgs.callPackage ./monof55.nix {};
}
