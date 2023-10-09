{pkgs, ...}: {
  services.screen-locker = {
    enable = true;
    inactiveInterval = 1;
    lockCmd = "${pkgs.betterlockscreen}/bin/betterlockscreen -l dim";
    xautolock.package = "${pkgs.xautolock}";
    xautolock.extraOptions = [
      "Xautolock.locker: systemctl suspend"
    ];
  };
}
