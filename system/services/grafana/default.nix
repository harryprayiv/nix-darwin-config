{
  config,
  pkgs,
  ...
}: {
  services.grafana = {
    enable = false;
    # Listening address and TCP port
    addr = "127.0.0.1";
    port = 3001;
    # Grafana needs to know on which domain and URL it's running:
    domain = "harryprayiv.bismuth/grafana";
    rootUrl = "https://harryprayiv.bismuth/grafana/"; # Not needed if it is `https://your.domain/`
  };
  # nginx reverse proxy
  # services.nginx.virtualHosts.${config.services.grafana.domain} = {
  #   locations."/" = {
  #       proxyPass = "http://127.0.0.1:${toString config.services.grafana.port}";
  #       proxyWebsockets = true;
  #   };
  # };
}
