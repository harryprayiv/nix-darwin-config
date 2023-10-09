{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ../../.././secrets/bismuth_intelTower.nix
    ./hardware-configuration.nix
    ../.././services
  ];

  nixpkgs.config = {
    allowUnfree = true;
    contentAddressedByDefault = true;
  };

  # Enable CUPS to print documents for my Brother printer.
  services.printing = {
    enable = true;
    drivers = [pkgs.brlaser];
  };

  # Use the systemd-boot EFI boot loader.
  boot = {
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    # kernelPackages = pkgs.linuxPackages_latest;
    initrd = {
      availableKernelModules = ["xhci_pci" "ehci_pci" "ahci" "firewire_ohci" "usbhid" "usb_storage" "sd_mod"];
      kernelModules = [];
    };
    kernelModules = ["kvm-intel"];
    extraModulePackages = [];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = ["zfs" "nfs" "btrfs"];
    zfs = {
      forceImportRoot = false;
      # extraPools = ["zpool"];
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget

  environment.systemPackages = [inputs.alejandra.defaultPackage.x86_64-linux];

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];

  services.flatpak.enable = true;

  # Half-hearted attempt to set environment variables for flatpak
  # environment = {
  #   XDG_DATA_DIRS = [
  #                   "/usr/share"
  #                   "/var/lib/flatpak/exports/share"
  #                   "$HOME/.local/share/flatpak/exports/share"
  #                   ];
  # };

  services.sysprof.enable = true;

  nix.settings.cores = 4;

  # Enable sound.
  sound = {
    enable = true;
    mediaKeys.enable = true;
  };

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  services = {
    avahi = {
      nssmdns = true;
      enable = true;
      publish = {
        enable = true;
        userServices = true;
        domain = true;
      };
    };
    xserver = {
      xrandrHeads = [
        {
          output = "HDMI-2";
          primary = true;
          monitorConfig = ''
            Option "PreferredMode" "1920x1080"
            Option "Position" "0 0"
          '';
        }
      ];
      resolutions = [
        {
          x = 1920;
          y = 1080;
        }
      ];
    };
  };
}
