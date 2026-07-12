{ lib, ... }:

{

  imports = [
    ../../../profiles/desktop
    # ../../../profiles/desktop/gaming
    ./disko.nix
  ];

  services.logrotate.enable = false;

  virtualisation.docker.enable = true;

  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.loader.grub = {
    efiSupport = lib.mkForce false;
    device = lib.mkForce "/dev/sda";
  };

  fileSystems."/swap" = {
    device = "/dev/mapper/rootfs";
    fsType = "btrfs";
    options = [
      "subvol=@swap"
      "noatime"
      "compress=none"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /swap 0700 root root - -"
    "H /swap +C - - - -"
  ];

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 8 * 1024;
      discardPolicy = "none";
    }
  ];

  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/" ];
  };
}
