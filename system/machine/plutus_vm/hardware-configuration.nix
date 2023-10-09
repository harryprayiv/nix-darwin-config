{pkgs, ...}: {
  # TODO: these are dummy file systems, get the proper one
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/7BB3-09C5";
    fsType = "vfat";
  };
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/0fddb262-13c1-46b1-9a5d-216766f47498";
    fsType = "ext4";
  };

  # If you are running within a VM and NixOS fails to import the zpool on reboot,
  # you may need to add
  # boot.zfs.devNodes = "/dev/disk/by-path"; # or
  # boot.zfs.devNodes = "/dev/disk/by-partuuid"; # to your configuration.nix file.
}
