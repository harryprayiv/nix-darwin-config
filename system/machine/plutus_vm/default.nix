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
    home = "/home/plutus_vm";
    uid = 1002;
    description = "PlutusVM DevConfig";
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
    openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3Nz[...] bismuth@plutus_vm"];
  };

  users.groups.plugdev = {};

  nixpkgs.config = {
    allowUnfree = true;
    contentAddressedByDefault = false;
    permittedInsecurePackages = [
      #"xrdp-0.9.9"
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
    hostName = "plutus_vm"; # Define your hostname.
    interfaces.eno1.useDHCP = true;
  };

  /*
   swapDevices =
  [ { device = "/dev/disk/by-uuid/6d522132-d549-414a-84c9-160687b22cac"; }
  ];
  */

  # Enable sound.
  sound = {
    enable = false;
    mediaKeys.enable = true;
  };

  hardware.pulseaudio = {
    enable = false;
    package = pkgs.pulseaudioFull;
  };

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

  services.xserver = {
    xrandrHeads = [
      {
        output = "Virtual-1";
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
}
