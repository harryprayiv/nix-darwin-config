{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
# with inputs.cardano-wallet.nixosModules.cardano-wallet;
let
  # topology          = "/nix/store/mb0zb61472xp1hgw3q9pz7m337rmfx7f-topology.yaml";
  # nodeconfig        = "/nix/store/4b0rmqn24w0yc2yvn33vlawwdxa3a71i-config-0-0.json";
  node_socket_path = "/var/lib/cardano-node/db-mainnet/node.socket";
  # db_path           = "/var/lib/cardano-node/db-mainnet";
in {
  environment.systemPackages = with pkgs; [
    inputs.cardano-wallet.packages.x86_64-linux.cardano-wallet
  ];

  services.config.cardano-wallet = with inputs.cardano-wallet.nixosModules.cardano-wallet; {
    enable = true;
    walletMode = "mainnet";
    nodeSocket = ${node_socket_path};
    poolMetadataFetching = {
      enable = true;
      smashUrl = "https://smash.cardano-mainnet.iohk.io";
    };
    tokenMetadataServer = "https://tokens.cardano.org";
  };
  # nixpkgs.overlays = [ cardano-node.overlay ];
  services.cardano-wallet.serviceConfig = {
    RestartSec = "3s";
    Restart = "always";
  };
}
