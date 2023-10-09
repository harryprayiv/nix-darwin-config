{pkgs, ...}: {
  # TODO: these are shit file systems, go btrfs or zfs or go home
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/83635777-72ad-40e5-b879-42db06150562";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/2F1A-A080";
    fsType = "vfat";
  };

  #hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
