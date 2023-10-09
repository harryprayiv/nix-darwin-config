# An example dashboard config from Sam Leathers at IOG
{
  services = {
    openssh = {
      passwordAuthentication = false;
      enable = true;
    };

    prometheus = {
      enable = true;
      extraFlags = [
        "--storage.tsdb.retention.time 8760h"
      ];
      scrapeConfigs = [
        {
          job_name = "prometheus";
          scrape_interval = "5s";
          static_configs = [
            {
              targets = [
                "localhost:9090"
              ];
            }
          ];
        }
        {
          job_name = "node";
          scrape_interval = "10s";
          static_configs = [
            {
              targets = [
                "localhost:9100"
              ];
              labels = {
                alias = "pskov-host";
              };
            }
          ];
        }
        {
          job_name = "cardano";
          scrape_interval = "10s";
          static_configs = [
            {
              targets = [
                "10.10.1.2:12798"
              ];
              labels = {
                alias = "leder-pool";
              };
            }
            {
              targets = [
                "10.10.1.4:12798"
              ];
              labels = {
                alias = "leder-relay";
              };
            }
            {
              targets = [
                "10.10.1.6:12798"
              ];
              labels = {
                alias = "leder-db-sync-node";
              };
            }
          ];
        }
        {
          job_name = "db-sync";
          scrape_interval = "10s";
          metrics_path = "/";
          static_configs = [
            {
              targets = [
                "localhost:8080"
              ];
              labels = {
                alias = "leder-db-sync";
              };
            }
          ];
        }
      ];
      exporters = {
        blackbox = {
          enable = true;
          configFile = pkgs.writeText "blackbox-exporter.yaml" (builtins.toJSON {
            modules = {
              https_2xx = {
                prober = "http";
                timeout = "5s";
                http = {
                  fail_if_not_ssl = true;
                };
              };
              htts_2xx = {
                prober = "http";
                timeout = "5s";
              };
              ssh_banner = {
                prober = "tcp";
                timeout = "10s";
                tcp = {
                  query_response = [{expect = "^SSH-2.0-";}];
                };
              };
              tcp_v4 = {
                prober = "tcp";
                timeout = "5s";
                tcp = {
                  preferred_ip_protocol = "ip4";
                };
              };
              tcp_v6 = {
                prober = "tcp";
                timeout = "5s";
                tcp = {
                  preferred_ip_protocol = "ip6";
                };
              };
              icmp_v4 = {
                prober = "icmp";
                timeout = "60s";
                icmp = {
                  preferred_ip_protocol = "ip4";
                };
              };
              icmp_v6 = {
                prober = "icmp";
                timeout = "5s";
                icmp = {
                  preferred_ip_protocol = "ip6";
                };
              };
            };
          });
        };
        node = {
          enable = true;
          enabledCollectors = [
            "systemd"
            "tcpstat"
            "conntrack"
            "diskstats"
            "entropy"
            "filefd"
            "filesystem"
            "loadavg"
            "meminfo"
            "netdev"
            "netstat"
            "stat"
            "time"
            "vmstat"
            "logind"
            "interrupts"
            "ksmd"
          ];
        };
      };
    };
    loki = {
      enable = true;
      configuration = {
        auth_enabled = false;

        ingester = {
          chunk_idle_period = "5m";
          chunk_retain_period = "30s";
          lifecycler = {
            address = "127.0.0.1";
            final_sleep = "0s";
            ring = {
              kvstore = {store = "inmemory";};
              replication_factor = 1;
            };
          };
        };

        limits_config = {
          enforce_metric_name = false;
          reject_old_samples = true;
          reject_old_samples_max_age = "168h";
          ingestion_rate_mb = 160;
          ingestion_burst_size_mb = 160;
        };

        schema_config = {
          configs = [
            {
              from = "2020-05-15";
              index = {
                period = "168h";
                prefix = "index_";
              };
              object_store = "filesystem";
              schema = "v11";
              store = "boltdb";
            }
          ];
        };

        server = {http_listen_port = 3100;};

        storage_config = {
          boltdb = {directory = "/var/lib/loki/index";};
          filesystem = {directory = "/var/lib/loki/chunks";};
        };
      };
    };
    grafana = {
      enable = true;
      addr = "0.0.0.0";
    };
  };
}
