{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  promtail = {
    enable = false;
    configuration = {
      server = {
        http_listen_port = 28183;
        grpc_listen_port = 0;
      };

      positions = {
        filename = "/tmp/positions.yaml";
      };

      clients = [
        {
          # TODO: get address of host running container
          url = "http://10.40.33.21:3100/loki/api/v1/push";
        }
      ];

      scrape_configs = [
        {
          job_name = "journal";
          journal = {
            max_age = "12h";
            labels = {
              job = "systemd-journal";
              # TODO: get container name to prevent clashing and make it easier to query
              host = "container_name";
            };
          };
          relabel_configs = [
            {
              source_labels = ["__journal__systemd_unit"];
              target_label = "unit";
            }
          ];
        }
      ];
    };
  };
}
