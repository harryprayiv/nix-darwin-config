{pkgs, ...}: let
  pgrep = "${pkgs.busybox}/bin/pgrep";
  topology = "/nix/store/mb0zb61472xp1hgw3q9pz7m337rmfx7f-topology.yaml";
  config = "/nix/store/4b0rmqn24w0yc2yvn33vlawwdxa3a71i-config-0-0.json";
  node_socket_path = "/var/lib/cardano-node/db-mainnet/node.socket";
  db_path = "/var/lib/cardano-node/db-mainnet";
  cardano-cli = "./cardano-cli";
  # cowsay            = "${pkgs.cowsay}/bin/cowsay";
  #cli-path          = "/nix/store/w6mlv2czw4r9kadql0l62ivl1ly6s28m-system-path/bin/cardano-cli";
in
  pkgs.writeShellScriptBin "node_check" ''
    if [ "$(${pgrep} cardano-node)" ]; then
      echo "Populating Path Variables:"
      export CARDANO_TOPOLOGY="${topology}"
      export CARDANO_CONFIG="${config}"
      export CARDANO_NODE_SOCKET_PATH=${node_socket_path}
      export CARDANO_DB_PATH="${db_path}"
      echo "Repopulating Path Variables:"
      echo "cardano-node app executable: ${cardano-cli} Make This DECLARATIVE" && echo "node socket path: ${node_socket_path}" && echo "database path: ${db_path}" && echo "config file: ${config}" && echo "topology: ${topology}"
      echo ""
      echo ""
      echo "cli version:"
      cardano-cli --version
      echo ""
      echo ""
      echo "Checking Node:"
      cardano-cli query tip --mainnet
      echo ""
      echo ""
      echo "Checking Specific Wallet Addresses (addr1v9rve53mm803ecw2elz78e3ugjg7l9nxdl53c980e3y89ycw3e5r6):"
      cardano-cli query utxo --address addr1v9rve53mm803ecw2elz78e3ugjg7l9nxdl53c980e3y89ycw3e5r6 --mainnet
      echo ""
      echo ""
      echo "Checking Specific Wallet Addresses (addr1qyk6kp3egk5458dfckjmtfrvjx59l78gx7wqjfpgrf9ga9pnmye2vcqtz6kqk3yc6fje4rkwmwh9fy469n7uhl5kc6aqece446):"
      cardano-cli query utxo --address addr1qyk6kp3egk5458dfckjmtfrvjx59l78gx7wqjfpgrf9ga9pnmye2vcqtz6kqk3yc6fje4rkwmwh9fy469n7uhl5kc6aqece446 --mainnet
    else
      echo "轢"
    fi
  ''
