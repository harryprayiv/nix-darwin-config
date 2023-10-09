{
  config,
  pkgs,
  callPackage,
  ...
}: {
  # GPS location hidden in secrets

  services.redshift = {
    enable = true;
    settings.redshift = {
      # Note the string values below.
      brightness-day = "1";
      brightness-night = "1";
    };
    temperature = {
      day = 5680;
      night = 2600;
    };
    provider = "manual";
  };
}
