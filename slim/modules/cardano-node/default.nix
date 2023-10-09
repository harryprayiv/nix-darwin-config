{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  inherit (inputs) cardano-node;
  # topology          = "/nix/store/mb0zb61472xp1hgw3q9pz7m337rmfx7f-topology.yaml";
  # nodeconfig        = "/nix/store/4b0rmqn24w0yc2yvn33vlawwdxa3a71i-config-0-0.json";
  # node_socket_path  = "/var/lib/cardano-node/db-mainnet/node.socket";
  # db_path           = "/var/lib/cardano-node/db-mainnet";
in {
  # nixpkgs.overlays = [ cardano-node.overlay ];
  # config.systemd.user.services.cardano-node = with inputs.cardano-node.nixosModules.cardano-node; {
  config.systemd.user.services.cardano-node = with inputs.cardano-node.nixosModules.cardano-node; {
    enable = true;
    package = inputs.cardano-node.packages.x86_64-linux.cardano-node;
    systemdSocketActivation = true;
    environment = "mainnet";
    environments = inputs.cardano-node.environments.x86_64-linux;
    rtsArgs = ["-N2" "-I0" "-A16m" "-qg" "-qb" "--disable-delayed-os-memory-return"];
    # useNewTopology = true;
    # topology = "${topology}";
    # nodeConfigFile = "${nodeconfig}";
    # databasePath = "${db_path}";
    # socketPath = "${node_socket_path}";
    # nodeId = 2;
    # extraNodeConfig = {
    #   hasPrometheus = [ "::" 12798 ];
    #   TraceMempool = false;
    #   setupScribes = [{
    #     scKind = "JournalSK";
    #     scName = "cardano";
    #     scFormat = "ScText";
    #   }];
    #   defaultScribes = [
    #     [
    #       "JournalSK"
    #       "cardano"
    #     ]
    #   ];
    # };
  };

  # systemd.sockets.cardano-node.partOf = [ "cardano-node.socket" ];
  # systemd.services.cardano-node.after = lib.mkForce [ "network-online.target" "cardano-node.socket" ];

  # environment.variables = {
  #   CARDANO_NODE_SOCKET_PATH = "/var/lib/cardano-node/db-mainnet/node.socket";
  # };

  # NAS mount point (node will write to default location if this doesn't exist)
  # fileSystems."/var/lib/cardano-node/db-mainnet" = {
  #   device = "192.168.1.212:/volume2/cardano-node/db-mainnet";
  #   options = [ "x-systemd.automount" "noauto" ];
  #   fsType = "nfs";
  # };

  # users.groups.cardano-node.gid = 1002;
}
