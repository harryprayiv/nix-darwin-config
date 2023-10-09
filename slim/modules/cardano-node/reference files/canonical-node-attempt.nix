{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
# with inputs.cardano-node.nixosModules.cardano-node;
let
  topology = "/nix/store/mb0zb61472xp1hgw3q9pz7m337rmfx7f-topology.yaml";
  nodeconfig = "/nix/store/4b0rmqn24w0yc2yvn33vlawwdxa3a71i-config-0-0.json";
  node_socket_path = "/var/lib/cardano-node/db-mainnet/node.socket";
  db_path = "/var/lib/cardano-node/db-mainnet";
in {
  environment.systemPackages = with pkgs; [
    inputs.cardano-node.packages.x86_64-linux.cardano-cli
  ];
  # nixpkgs.overlays = [ cardano-node.overlay ];
  services.cardano-node = with inputs.cardano-node.nixosModules.cardano-node; {
    enable = true;
    package = inputs.cardano-node.packages.x86_64-linux.cardano-node;
    systemdSocketActivation = true;
    environment = "mainnet";
    environments = inputs.cardano-node.environments.x86_64-linux;
    useNewTopology = true;
    topology = "${topology}";
    nodeConfigFile = "${nodeconfig}";
    # databasePath = "${db_path}";
    # socketPath = "${node_socket_path}";
    rtsArgs = ["-N2" "-I0" "-A16m" "-qg" "-qb" "--disable-delayed-os-memory-return"];
    nodeId = "bismuthian Test!!!";
  };
  systemd.sockets.cardano-node.partOf = ["cardano-node.socket"];
  systemd.services.cardano-node.after = lib.mkForce ["network-online.target" "cardano-node.socket"];
}
