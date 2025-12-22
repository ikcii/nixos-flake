{ lib, ... }:

{
  
  imports = [
    ../../../profiles/desktop
    ../../../profiles/desktop/gaming
  ];

  services.logrotate.enable = false;

  nixpkgs.config.rocmSupport = true;

  virtualisation.docker.enable = true;

  swapDevices = [{
    device = "/var/lib/swapfile";
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
