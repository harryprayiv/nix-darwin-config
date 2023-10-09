{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cncliPkgs = with inputs.cncli.packages.x86_64-linux; [
    cncli
  ];

  cardanoPkgs = with inputs.cardano-node.packages.x86_64-linux; [
    bech32
    cabalProjectRegenerate
    cardano-cli
    cardano-node
    cardano-node-chairman
    cardano-ping
    cardano-submit-api
    cardano-testnet
    cardano-topology
    cardano-tracer
    chain-sync-client-with-ledger-state
    db-analyser
    db-converter
    db-synthesizer
    ledger-state
    locli
    plutus-example
    scan-blocks
    scan-blocks-pipelined
    tx-generator
  ];
in {
  home.packages = cardanoPkgs ++ cncliPkgs;
}
