{pkgs, ...}: let
  home = "/home/bismuth";
  topology = "/nix/store/mb0zb61472xp1hgw3q9pz7m337rmfx7f-topology.yaml";
  config = "/nix/store/4b0rmqn24w0yc2yvn33vlawwdxa3a71i-config-0-0.json";
  node_socket_path = "/var/lib/cardano-node/db-mainnet/node.socket";
  db_path = "/var/lib/cardano-node/db-mainnet";

  cardano-cli = "./cardano-cli";
  cli-path = "/cardano_local/cardano-node/cardano-cli-build/bin";
  dapp_address = "addr1qyk6kp3egk5458dfckjmtfrvjx59l78gx7wqjfpgrf9ga9pnmye2vcqtz6kqk3yc6fje4rkwmwh9fy469n7uhl5kc6aqece446";
  dapp_coll = "addr1qyf0vwvkgfhdmrva5jmkttux752eemqe53psyr4hpjpt6qfnmye2vcqtz6kqk3yc6fje4rkwmwh9fy469n7uhl5kc6aqsqlpyw";
in
  pkgs.writeShellScriptBin "node_gen_json" ''
    #!/run/current-system/sw/bin/bash

    echo "Repopulating Path Variables:"
    CARDANO_TOPOLOGY="${topology}"
    CARDANO_CONFIG="${config}"
    CARDANO_NODE_SOCKET_PATH=${node_socket_path}
    CARDANO_DB_PATH="${db_path}"
    cd ${home}${cli-path}
    echo "Repopulating Path Variables:"
    echo "cardano-node app executable: ${cardano-cli}" && echo "node socket path: ${node_socket_path}" && echo "database path: ${db_path}" && echo "config file: ${config}" && echo "topology: ${topology}"
    echo ""
    echo ""
    echo "cli version:"
    ${cardano-cli} --version
    echo ""
    echo ""
    echo "Checking Node:"
    ${cardano-cli} query tip --mainnet
    echo ""
    echo ""
    echo "Checking Specific Wallet Addresses (addr1v9rve53mm803ecw2elz78e3ugjg7l9nxdl53c980e3y89ycw3e5r6):"
    ${cardano-cli} query utxo --address addr1v9rve53mm803ecw2elz78e3ugjg7l9nxdl53c980e3y89ycw3e5r6 --mainnet
    echo ""
    echo ""
    echo "Checking Specific Wallet Addresses (addr1qyk6kp3egk5458dfckjmtfrvjx59l78gx7wqjfpgrf9ga9pnmye2vcqtz6kqk3yc6fje4rkwmwh9fy469n7uhl5kc6aqece446):"
    ${cardano-cli} query utxo --address addr1qyk6kp3egk5458dfckjmtfrvjx59l78gx7wqjfpgrf9ga9pnmye2vcqtz6kqk3yc6fje4rkwmwh9fy469n7uhl5kc6aqece446 --mainnet
    ${cardano-cli} query utxo --address ${dapp_address} --mainnet --out-file ${home}/cardano_local/${dapp_address}.json
    ${cardano-cli} query utxo --address ${dapp_coll} --mainnet --out-file ${home}/cardano_local/${dapp_coll}.json
    ${cardano-cli} query utxo --address ${dapp_address} --mainnet
    echo ""
    echo ""
    echo "1666 : " && (echo -n "544f4b454e" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "6362544843" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "52415645" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "574f4c46" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "776f726c646d6f62696c65746f6b656e" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "50524f584945" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "4d494e" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "4d494e74" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "4249534f4e" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "5045524e4953" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "47726f777468" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "494147" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "4d454c44" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "456d706f7761" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "434458" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "56594649" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "4c4f4253544552" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "5041564941" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "4d494c4b" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "41414441" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "52455655" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "53554e444145" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "484f534b59" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "58524159" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "44524950" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "4153484942" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "634e455441" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "4c454146544f4b454e" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "474f4b4559" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "44414e41" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "436861726c7a20546f6b656e" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "436172646f67656f" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "464c49434b" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "436861726c7a20546f6b656e" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "52656465656d61626c65" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "414441464f58" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "4d494c4b" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "41474958" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "534f554c" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "474f4b4559" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "497463687942757474" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "5069737369427578" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "497463687942757474" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "5069737369427578" | xxd -ps -r | tr -d '\n')
    echo ""
    (echo -n "4d494c4b"	"634e455441" "4c454146544f4b454e" "534f554c	4d454c44	4249534f4e	52415645	776f726c646d6f62696c65746f6b656e	484f534b59	47726f777468	6362544843	52656465656d61626c65	52455655	434458	41474958	41414441	436172646f67656f	4d494e74	4d494e	434845525259	4.44E+45	56594649	4153484942	58524159	544f4b454e	474f4b4559	4c4f4253544552	5041564941	50524f584945	414441464f58	436861726c7a20546f6b656e	456d706f7761	574f4c46	44524950	444f4558	53554e444145	494147	464c49434b	5045524e4953" | xxd -ps -r | tr -d '\n')
  ''
