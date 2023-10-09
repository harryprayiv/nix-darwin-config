{
  config,
  lib,
  pkgs,
  inputs,
  specialArgs,
  ...
}:
with lib; let
  cfg = config.services.cardano-node;

  package = inputs.cardano-node.packages.x86_64-linux.cardano-node;
in {
  meta.maintainers = [hm.maintainers.bismuth];

  options.programs.cardano-node = {
    enable = mkEnableOption "Syncing tool for Mega.nz";
  };

  config = mkIf cfg.enable {
    home.packages = [
      (
        if specialArgs.ultraHD
        then ultraHDPackage
        else package
      )
    ];
  };
}
# { config, pkgs, lib, inputs, specialArgs, ... }:
# with inputs.cardano-node.nixosModules.cardano-node;
# let
#   topology          = "/nix/store/mb0zb61472xp1hgw3q9pz7m337rmfx7f-topology.yaml";
#   nodeconfig        = "/nix/store/4b0rmqn24w0yc2yvn33vlawwdxa3a71i-config-0-0.json";
#   node_socket_path  = "/var/lib/cardano-node/db-mainnet/node.socket";
#   db_path           = "/var/lib/cardano-node/db-mainnet";
# in
# {
#   # nixpkgs.overlays = [ cardano-node.overlay ];
#   systemd.users.services.cardano-node = with inputs.cardano-node.nixosModules.cardano-node; {
#       enable = true;
#       package = inputs.cardano-node.packages.x86_64-linux.cardano-node;
#       systemdSocketActivation = true;
#       environment = "mainnet";
#       environments = inputs.cardano-node.environments.x86_64-linux;
#       useNewTopology = true;
#       topology = "${topology}";
#       nodeConfigFile = "${nodeconfig}";
#       # databasePath = "${db_path}";
#       # socketPath = "${node_socket_path}";
#       rtsArgs = [ "-N2" "-I0" "-A16m" "-qg" "-qb" "--disable-delayed-os-memory-return" ];
#       # nodeId = "1";
#       after = lib.mkForce [ "network-online.target" "cardano-node.socket" ];
#   };
#   systemd.sockets.cardano-node.partOf = [ "cardano-node.socket" ];
# }

