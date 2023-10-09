{
  # Remove sound.enable or turn it off if you had it set previously, it seems to cause conflicts with pipewire
  sound.enable = false;
  # rtkit is optional but recommended
  security.rtkit.enable = true;
  services.pipewire = {
    /*
           config.pipewire = {
        "context.properties" = {
          #"link.max-buffers" = 64;
          "link.max-buffers" = 16; # version < 3 clients can't handle more than this
          "log.level" = 2; # https://docs.pipewire.org/page_daemon.html
          #"default.clock.rate" = 48000;
          #"default.clock.quantum" = 1024;
          #"default.clock.min-quantum" = 32;
          #"default.clock.max-quantum" = 8192;
      };
    };
    */
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };
}
