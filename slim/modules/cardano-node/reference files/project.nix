{
  self,
  nixpkgs,
  sops-nix,
  inputs,
  nixos-hardware,
  cardano-node,
  nix,
  #, cardano-db-sync
  ...
}: let
  nixosSystem = nixpkgs.lib.makeOverridable nixpkgs.lib.nixosSystem;

  customModules = import ../modules/modules-list.nix;
  baseModules = [
    # make flake inputs accessiable in NixOS
    {_module.args.inputs = inputs;}
    {
      imports = [
        ({pkgs, ...}: {
          nix.nixPath = [
            "nixpkgs=${pkgs.path}"
          ];
          # TODO: remove when switching to 22.05
          nix.package = nixpkgs.lib.mkForce nix.packages.x86_64-linux.nix;
          nix.extraOptions = ''
            experimental-features = nix-command flakes
          '';
          documentation.info.enable = false;
        })
        when
        #./modules/upgrade-diff.nix # TODO: look at these from Mic92
        #./modules/nix-daemon.nix
        #./modules/minimal-docs.nix
        sops-nix.nixosModules.sops
      ];
    }
  ];
  defaultModules = baseModules ++ customModules;
in {
  sarov = nixosSystem {
    system = "x86_64-linux";
    modules =
      defaultModules
      ++ [
        cardano-node.nixosModules.cardano-node # no idea why this works here but not in sarov/configuration.nix
        ./sarov/configuration.nix
      ];
  };
}
