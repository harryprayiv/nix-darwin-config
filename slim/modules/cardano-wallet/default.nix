{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.cardano-wallet.nixosModule
  ];
  services.config.cardano-wallet = {
    enable = true;
    walletMode = "mainnet";
    # nodeSocket = config.services.cardano-node.socketPath;
    poolMetadataFetching = {
      enable = true;
      smashUrl = "https://smash.cardano-mainnet.iohk.io";
    };
    tokenMetadataServer = "https://tokens.cardano.org";
  };
}
