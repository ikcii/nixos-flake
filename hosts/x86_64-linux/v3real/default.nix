{ lib, pkgs, ... }:

{

  imports = [
    ../../../profiles/desktop
    ../../../profiles/desktop/gaming
    ./disko.nix
  ];

  services.logrotate.enable = false;

  nixpkgs.config.rocmSupport = true;

  virtualisation.docker.enable = true;

  fileSystems."/swap" = {
    device = "/dev/mapper/rootfs";
    fsType = "btrfs";
    options = [
      "subvol=@swap"
      "noatime"
      "compress=none"
      "discard=async"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /swap 0700 root root - -"
    "H /swap +C - - - -"
  ];

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 32 * 1024;
      discardPolicy = "both";
    }
  ];

  environment.variables = {
    "HSA_OVERRIDE_GFX_VERSION" = "11.0.0";
    "ROC_ENABLE_PRE_VEGA" = "1";
    "LIBVA_DRIVER_NAME" = "radeonsi";
  };

  services.fstrim.enable = true;
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/" ];
  };

  environment.systemPackages = with pkgs; [
    git
    git-lfs
  ];

  services.forgejo = {
    enable = true;
    lfs.enable = true;

    settings = {
      server = {
        DOMAIN = "git.ikci.dev";
        ROOT_URL = "https://git.ikci.dev";
        HTTP_PORT = 3000;
      };

      service = {
        DISABLE_REGISTRATION = true;
      };
    };
  };

  systemd.services.cloudflared-tunnel = {
    description = "Cloudflare Tunnel for Git";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run";
      EnvironmentFile = "/etc/cloudflared.env";
      Restart = "always";
      DynamicUser = true;
    };
  };
}
