{pkgs, ...}: {
  # TODO: these are shit file systems, go btrfs or zfs or go home
  fileSystems."/boot" = {
    # device = "/dev/disk/by-uuid/E190-B72F";
    fsType = "vfat";
  };
  fileSystems."/" = {
    # device = "/dev/disk/by-uuid/b7936e98-ae0f-4c3d-99f1-c27b97968d58";
    fsType = "ext4";
  };
}
