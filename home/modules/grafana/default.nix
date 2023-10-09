{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  services.config.grafana = {
    enable = true;
    # Listening address and TCP port
    addr = "127.0.0.1";
    port = 3000;
    # Grafana needs to know on which domain and URL it's running:
    domain = "your.domain";
    rootUrl = "https://your.domain/grafana/"; # Not needed if it is `https://your.domain/`
  };
}
# Get this dashboard
/*
Data source:
https://grafana.com/grafana/dashboards/12469-cardano-node-stakepool-overview/
Grafana 7.0.5
Loki 1.0.0
Prometheus 1.0.0
*/
/*
Dependencies:
Graph (old)
Logs
Singlestat
*/

