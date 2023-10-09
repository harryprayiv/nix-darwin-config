{
  pkgs,
  inputs,
  ...
}: let
  CNODEBIN = "/nix/store/q95b52ssb56x0m8gr1msyab7vnfck3bn-cardano-node-exe-cardano-node-1.36.0/bin/cardano-node"; # Override automatic detection of cardano-node executable
  CCLI = "/nix/store/c4fw2qdsn4izygig458hjdz9fs102lxc-cardano-cli-exe-cardano-cli-1.36.0/bin/cardano-cli"; # Override automatic detection of cardano-cli executable
  CNCLI = "/home/$USER/cardano_local/guild-operators/scripts/cnode-helper-scripts/"; # Override automatic detection of executable (https://github.com/AndrewWestberg/cncli)
  CNODE_HOME = "/home/$USER/cardano_local/cardano-node/"; # Override default CNODE_HOME path (defaults to /opt/cardano/cnode)
  CNODE_PORT = 3001; # Set node port
  CONFIG = "/nix/store/4b0rmqn24w0yc2yvn33vlawwdxa3a71i-config-0-0.json"; # Override automatic detection of node config path
  SOCKET = "${CNODE_HOME}state-node-mainnet/node.socket"; # Override automatic detection of path to socket
  TOPOLOGY = "/nix/store/mb0zb61472xp1hgw3q9pz7m337rmfx7f-topology.yaml"; # Override default topology.json path
  LOG_DIR = "${CNODE_HOME}/logs"; # Folder where your logs will be sent to (must pre-exist)
  DB_DIR = "${CNODE_HOME}/db"; # Folder to store the cardano-node blockchain db
  #UPDATE_CHECK="Y"                                       # Check for updates to scripts, it will still be prompted before proceeding (Y|N).
  TMP_DIR = "/tmp/cnode"; # Folder to hold temporary files in the various scripts, each script might create additional subfolders
  USE_EKG = "N"; # Use EKG metrics from the node instead of Prometheus. Prometheus metrics yield slightly better performance but can be unresponsive at times (default EKG)

  guildViewPkgs = with pkgs; [
    bc # required for Cardano Guild gLiveView
  ];
in {
  home.packages = guildViewPkgs;

  programs.guild_op = {
    enable = true;

    profiles = {
      "mainnet_Relay" = {
        environment = "testnet";
        priority = "1";
        fingerprint = {
          cardanoID = ${nodeIdentifier};
        };

        config = {
          enable = true;
          rate = "normal";
        };
      };
    };
  };
}
