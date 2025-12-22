{ lib, ... }:

{
  
  imports = [
    ../../../profiles/desktop
    ../../../profiles/desktop/gaming
  ];

  services.logrotate.enable = false;

  nixpkgs.config.rocmSupport = true;

  virtualisation.docker.enable = true;

  zramSwap = {
    enable = true;
    memoryPercent = 20;
  };

  fileSystems."/swap" = {
    device = "/dev/mapper/rootfs";
    fsType = "btrfs";
    options = [ "subvol=@swap" "noatime" "compress=none" ];
  };

  systemd.tmpfiles.rules = [
    "d /swap 0700 root root - -"
    "H /swap +C - - - -"
  ];

  swapDevices = [{
    device = "/swap/swapfile";
    size = 32*1024;
  }];

  environment.variables = {
    "HSA_OVERRIDE_GFX_VERSION" = "11.0.0";
    "ROC_ENABLE_PRE_VEGA" = "1";
  };

  fileSystems."/" = {
    options = lib.mkForce [ "subvol=@" "compress=zstd:1" "noatime" ];
  };

  fileSystems."/home" = {
    options = lib.mkForce [ "subvol=@home" "compress=zstd:1" "noatime" ];
  };

  fileSystems."/nix" = {
    options = lib.mkForce [ "subvol=@nix" "compress=zstd:1" "noatime" ];
  };

  fileSystems."/var/log" = {
    options = lib.mkForce [ "subvol=@log" "compress=zstd:1" "noatime" ];
  };

  boot.initrd.luks.devices."rootfs".allowDiscards = true;

  services.fstrim.enable = true;
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/" ];
  };
}
