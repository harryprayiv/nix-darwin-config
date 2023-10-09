# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  sops.defaultSopsFile = ./secrets.yaml;
  sops.secrets.pool_opcert = {};
  sops.secrets.pool_vrf_skey = {};
  sops.secrets.pool_kes_skey = {};
in {
  containers = {
    pool = {
      bindMounts = {
        "/run/secrets/pool_opcert" = {
          hostPath = "/run/secrets/pool_opcert";
          isReadOnly = true;
        };
        "/run/secrets/pool_kes_skey" = {
          hostPath = "/run/secrets/pool_kes_skey";
          isReadOnly = true;
        };
        "/run/secrets/pool_vrf_skey" = {
          hostPath = "/run/secrets/pool_vrf_skey";
          isReadOnly = true;
        };
      };
      bindMounts."/pool-keys" = {
        hostPath = "/var/leder-keys";
        isReadOnly = false;
      };
      config = {
        services.cardano-node = {
          ipv6HostAddr = "::";
          topology = __toFile "topology.json" (__toJSON {
            Producers = [
              {
                addr = "relay.valaam.lan.disasm.us";
                port = 3001;
                valency = 1;
              }
            ];
          });
          operationalCertificate = "/var/lib/cardano-node/opcert";
          kesKey = "/var/lib/cardano-node/kes.skey";
          vrfKey = "/var/lib/cardano-node/vrf.skey";
        };
        systemd.services.cardano-node.preStart = ''
          cp /run/secrets/pool_opcert /var/lib/cardano-node/opcert
          cp /run/secrets/pool_vrf_skey /var/lib/cardano-node/vrf.skey
          cp /run/secrets/pool_kes_skey /var/lib/cardano-node/kes.skey
          chown cardano-node /var/lib/cardano-node/opcert
          chown cardano-node /var/lib/cardano-node/vrf.skey
          chown cardano-node /var/lib/cardano-node/kes.skey
        '';
        systemd.services.cardano-node.serviceConfig.PermissionsStartOnly = true;
      };
    };
    relay = {
      bindMounts."/run/cardano-node" = {
        hostPath = "/relay-run-cardano";
        isReadOnly = false;
      };
      config = {
        services.cardano-node = {
          ipv6HostAddr = "::";
          extraNodeConfig.TestEnableDevelopmentNetworkProtocols = true;
          producers = [
            {
              accessPoints = [
                {
                  address = "2a07:c700:0:503::1";
                  port = 1025;
                }
                {
                  address = "2a07:c700:0:505::1";
                  port = 6021;
                }
                {
                  address = "2600:1700:fb0:fd00::77";
                  port = 4564;
                }
                {
                  address = "testnet.weebl.me";
                  port = 3123;
                }
                {
                  address = "pool.valaam.lan.disasm.us";
                  port = 3001;
                }
              ];
              advertise = false;
              valency = 1;
            }
          ];
          publicProducers = [
            {
              accessPoints = [
                {
                  address = "relays.vpc.cardano-testnet.iohkdev.io";
                  port = 3001;
                }
              ];
              advertise = false;
            }
          ];
          useNewTopology = true;
        };
      };
    };
    db-sync = {
      hostAddress = "10.10.1.5";
      localAddress = "10.10.1.6";
      config = {
        imports = [pkgs'.cardanoDBSyncModule];
        services.cardano-node = {
          hostAddr = "10.10.1.6";
          topology = __toFile "topology.json" (__toJSON {
            Producers = [
              {
                addr = "10.10.1.4";
                port = 3001;
                valency = 1;
              }
            ];
          });
        };
        services.cardano-db-sync = {
          cluster = "mainnet";
          enable = false;
          socketPath = "/run/cardano-node/node.socket";
          user = "cexplorer";
          extended = true;
          postgres = {
            database = "cexplorer";
          };
        };
        services.postgresql = {
          enable = true;
          enableTCPIP = false;
          settings = {
            max_connections = 200;
            shared_buffers = "2GB";
            effective_cache_size = "6GB";
            maintenance_work_mem = "512MB";
            checkpoint_completion_target = 0.7;
            wal_buffers = "16MB";
            default_statistics_target = 100;
            random_page_cost = 1.1;
            effective_io_concurrency = 200;
            work_mem = "10485kB";
            min_wal_size = "1GB";
            max_wal_size = "2GB";
          };
          identMap = ''
            explorer-users /postgres postgres
            explorer-users /cexplorer cexplorer
          '';
          authentication = ''
            local all all ident map=explorer-users
            local all all trust
          '';
          ensureDatabases = [
            "cexplorer"
          ];
          ensureUsers = [
            {
              name = "cexplorer";
              ensurePermissions = {
                "DATABASE cexplorer" = "ALL PRIVILEGES";
                "ALL TABLES IN SCHEMA public" = "ALL PRIVILEGES";
              };
            }
          ];
        };

        users.users.cexplorer.isSystemUser = true;
        systemd.services.cardano-db-sync.serviceConfig = {
          SupplementaryGroups = "cardano-node";
          Restart = "always";
          RestartSec = "30s";
        };
      };
    };
  };
}
