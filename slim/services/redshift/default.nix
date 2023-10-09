{
  config,
  pkgs,
  callPackage,
  ...
}: {
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
    latitude = 42.4363258;
    longitude = -71.0801245;
  };
}
