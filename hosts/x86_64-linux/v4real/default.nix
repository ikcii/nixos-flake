# Host-specific settings for the 'v4real' desktop
{ pkgs, ... }:

{

  imports = [
    ../../../profiles/desktop
    ../../../profiles/desktop/gaming
    ./disko.nix
  ];

  # --- Graphics & NVIDIA PRIME Offload ---
  services.xserver.videoDrivers = [
    "modesetting"
    "nvidia"
  ];

  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
    powerManagement.enable = true;
    nvidiaSettings = true;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  hardware.bluetooth.enable = true;

  services.blueman.enable = true;

  virtualisation.docker.enable = true;

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
      EnvironmentFile = "/etc/cloudflared-git.env";
      Restart = "always";
      DynamicUser = true;
    };
  };

  services.nextcloud = {
    enable = true;
    hostName = "cloud.ikci.dev";
    package = pkgs.nextcloud34;

    database.createLocally = true;

    config = {
      dbtype = "pgsql";
      adminuser = "admin";
      adminpassFile = "/etc/nextcloud-admin-pass";
    };

    settings = {
      overwriteprotocol = "https";
      overwritehost = "cloud.ikci.dev";
      trusted_proxies = [
        "127.0.0.1"
        "::1"
      ];
      "files.chunked_upload.max_size" = 99000000;
    };
  };

  systemd.services.cloudflared-cloud-tunnel = {
    description = "Cloudflare Tunnel for Nextcloud";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run";
      EnvironmentFile = "/etc/cloudflared-cloud.env";
      Restart = "always";
      DynamicUser = true;
    };
  };

  services.nextcloud-whiteboard-server = {
    enable = true;
    secrets = [ "/etc/nextcloud-whiteboard-secret" ];
    settings = {
      NEXTCLOUD_URL = "https://cloud.ikci.dev";
    };
  };

  services.collabora-online = {
    enable = true;
    port = 9980;
    settings = {
      server_name = "office.ikci.dev";
      ssl = {
        enable = false;
        termination = true;
      };
      net = {
        lok_allow.host = [
          "cloud\\.ikci\\.dev"
          "127\\.0\\.0\\.1"
          "::1"
        ];
        post_allow.host = [
          "cloud\\.ikci\\.dev"
          "127\\.0\\.0\\.1"
          "::1"
        ];
      };
      storage.wopi = {
        "@allow" = true;
        host = [
          "cloud\\.ikci\\.dev"
          "127\\.0\\.0\\.1"
          "::1"
        ];
      };
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };
  networking.firewall.interfaces."zt+".allowedTCPPorts = [ 22 ];
}
