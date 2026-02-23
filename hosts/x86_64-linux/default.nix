# Settings for all x86_64-linux systems
{ lib, pkgs, ... }:

{
  # --- Bootloader ---
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
    };
  };
  boot.tmp.cleanOnBoot = true;

  # --- Kernel ---
  # Default to latest kernel
  boot.kernelPackages = lib.mkOptionDefault pkgs.linuxPackages_latest;

  # --- Hardware & Drivers ---
  hardware.enableAllFirmware = true;
  hardware.graphics.enable = true;

  # --- Console & Keymaps ---
  console.useXkbConfig = true;

  # --- ZeroTier ---
  services.zerotierone.enable = true;

  # --- x86_64-linux Packages ---
  environment.systemPackages = with pkgs; [
    activate-linux
  ];

  # --- Encrypted DNS ---
  networking.networkmanager.dns = "none";
  networking.nameservers = [
    "127.0.0.1"
    "::1"
  ];
  services.unbound = {
    enable = true;
    settings = {
      server = {
        interface = [
          "127.0.0.1"
          "::1"
        ];
        access-control = [
          "127.0.0.0/8 allow"
          "::1/128 allow"
        ];

        hide-identity = "yes";
        hide-version = "yes";
      };

      forward-zone = [
        # Arma
        {
          name = "bohemia.net";
          forward-addr = [
            "194.242.2.2@853#dns.mullvad.net"
            "2a07:e340::2@853#dns.mullvad.net"
          ];
          forward-tls-upstream = "yes";
        }
        {
          name = "armaplatform.com";
          forward-addr = [
            "194.242.2.2@853#dns.mullvad.net"
            "2a07:e340::2@853#dns.mullvad.net"
          ];
          forward-tls-upstream = "yes";
        }
        {
          name = "bistudio.com";
          forward-addr = [
            "194.242.2.2@853#dns.mullvad.net"
            "2a07:e340::2@853#dns.mullvad.net"
          ];
          forward-tls-upstream = "yes";
        }

        # Global
        {
          name = ".";
          forward-addr = [
            "194.242.2.4@853#base.dns.mullvad.net"
            "2a07:e340::4@853#base.dns.mullvad.net"
          ];
          forward-tls-upstream = "yes";
        }
      ];
    };
  };
}
