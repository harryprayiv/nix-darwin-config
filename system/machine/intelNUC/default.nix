{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib; {
  imports = [
    ./hardware-configuration.nix
    ../.././services
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.bismuth = with inputs; {
    isNormalUser = true;
    home = "/home/bismuth";
    uid = 1002;
    description = "Harry Pray IV";
    extraGroups = [
      "docker"
      "networkmanager"
      "wheel"
      "scanner"
      "lp"
      "plugdev"
      "cardano-node"
      "cardano-wallet"
    ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3Nz[...] bismuth@intelTower"];
  };

  users.groups.plugdev = {};

  nixpkgs.config = {
    allowUnfree = true;
    contentAddressedByDefault = true;
    permittedInsecurePackages = [
      "xrdp-0.9.9"
    ];
  };

  # Enable CUPS to print documents for my Brother printer.
  services.printing = {
    enable = true;
    drivers = [pkgs.brlaser];
  };

  # Use the systemd-boot EFI boot loader.
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
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
  };

  networking = {
    hostName = "intelTower"; # Define your hostname.
    interfaces.eno1.useDHCP = true;
    interfaces.eth0.useDHCP = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # virt-manager
  ];

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

  swapDevices = [
    {device = "/dev/disk/by-uuid/6d522132-d549-414a-84c9-160687b22cac";}
  ];

  fileSystems."/home/bismuth/video" = {
    device = "192.168.1.212:/volume2/video";
    options = ["x-systemd.automount" "noauto"];
    fsType = "nfs";
  };

  fileSystems."/home/bismuth/Cardano" = {
    device = "192.168.1.212:/volume2/Cardano";
    options = ["x-systemd.automount" "noauto"];
    fsType = "nfs";
  };

  fileSystems."/home/bismuth/Programming" = {
    device = "192.168.1.212:/volume2/Programming";
    options = ["x-systemd.automount" "noauto"];
    fsType = "nfs";
  };

  fileSystems."/home/bismuth/plutus" = {
    device = "192.168.1.212:/volume2/homes/plutus";
    options = ["x-systemd.automount" "noauto"];
    fsType = "nfs";
  };

  fileSystems."/home/bismuth/music" = {
    device = "192.168.1.212:/volume2/music";
    options = ["x-systemd.automount" "noauto"];
    fsType = "nfs";
  };

  fileSystems."/home/bismuth/shared_photos" = {
    device = "192.168.1.212:/volume2/shared_photos";
    options = ["x-systemd.automount" "noauto"];
    fsType = "nfs";
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
