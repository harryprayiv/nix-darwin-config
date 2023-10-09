{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  # topology          = "/nix/store/mb0zb61472xp1hgw3q9pz7m337rmfx7f-topology.yaml";
  # nodeconfig        = "/nix/store/4b0rmqn24w0yc2yvn33vlawwdxa3a71i-config-0-0.json";
  node_socket_path = "/zpool/cardano-node/db-mainnet/node.socket";
  db_path = "/zpool/cardano-node/db-mainnet";
  # signingKey_path = "";
  # delegationCertificate_path = "";
  # kesKey_path = "";
  # vrfKey_path = "";
  # opCert_path = "";
in {
  services.cardano-node = with inputs.cardano-node.nixosModules.cardano-node; {
    enable = true;
    package = inputs.cardano-node.packages.x86_64-linux.cardano-node;
    systemdSocketActivation = true;
    environment = "mainnet";
    environments = inputs.cardano-node.environments.x86_64-linux;
    rtsArgs = ["-N2" "-I0" "-A16m" "-qg" "-qb" "--disable-delayed-os-memory-return"];

    # topology = "${topology}";
    # nodeConfigFile = "${nodeconfig}";
    # databasePath = "${db_path}";
    # socketPath = "${node_socket_path}";

    # instances = 2;
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

    # isProducer = true;

    # Byron signing/delegation
    # signingKey = ${signingKey_path};
    # delegationCertificate = ${delegationCertificate_path};

    # # Shelley kes/vrf keys and operation cert
    # kesKey = ${kesKey_path};
    # vrfKey = ${vrfKey_path};
    # operationalCertificate = ${opCert_path};
  };

  systemd.sockets.cardano-node.partOf = ["cardano-node.socket"];
  systemd.services.cardano-node = {
    after = lib.mkForce ["network-online.target" "cardano-node.socket"];
  };

  nixpkgs.overlays = [inputs.cardano-node.overlay];

  environment.systemPackages = with inputs.cardano-node.packages.x86_64-linux; [
    bech32
    cabalProjectRegenerate
    cardano-cli
    cardano-submit-api
    cardano-testnet
    cardano-topology
    cardano-tracer
    chain-sync-client-with-ledger-state
    db-analyser
    db-synthesizer
    ledger-state
    locli
    scan-blocks
    scan-blocks-pipelined
    tx-generator
  ];

  # users.groups.cardano-node.gid = 10016;
  # users.groups.cardano-cli.gid = 10016;
  users.extraGroups.cardano-node.members = ["bismuth"];
  users.groups.cardano-node.gid = 10016;
  # fileSystems."/var/lib/cardano-node" = {
  #   device = "192.168.1.212:/volume2/cardano-node";
  #   fsType = "nfs";
  # };

  environment.variables = {
    CARDANO_NODE_SOCKET_PATH = "/var/lib/cardano-node/db-mainnet/node.socket";
  };

  #   environment.variables = {
  #   CARDANO_NODE_SOCKET_PATH = "/relay-run-cardano/node.socket";
  # };

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.systemd1.manage-units" &&
            action.lookup("unit") == "cardano-node.service" &&
            subject.isInGroup("wheel")) {
            return polkit.Result.YES;
        }
    });
  '';
}
