# Settings for all x86_64-linux systems
{ lib, pkgs, ... }:

{
  # Bootloader
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

  # Kernel
  boot.kernelPackages = lib.mkDefault pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto;

  # Hardware & Drivers
  hardware.enableAllFirmware = true;
  hardware.graphics.enable = true;

  # Console & Keymaps
  console.useXkbConfig = true;

  # ZeroTier
  services.zerotierone.enable = true;

  # x86_64-linux Packages
  environment.systemPackages = with pkgs; [
    activate-linux
  ];

  # zram
  zramSwap.enable = true;

  # Encrypted DNS
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

      forward-zone =
        let
          mkMinimal = domainName: {
            name = domainName;
            forward-addr = [
              "9.9.9.11@853#dns.quad9.net"
              "2620:fe::fe:11@853#dns.quad9.net"
            ];
            forward-tls-upstream = "yes";
          };

          mkEnhanced = domainName: {
            name = domainName;
            forward-addr = [
              "9.9.9.12@853#dns.quad9.net"
              "2620:fe::fe:12@853#dns.quad9.net"
            ];
            forward-tls-upstream = "yes";
          };
        in
        [
          (mkMinimal "bohemia.net")
          (mkMinimal "armaplatform.com")
          (mkMinimal "bistudio.com")
          (mkMinimal "fincrafters.pl")

          # Global - enhanced (blocks ads, tracking, malware)
          (mkEnhanced ".")
        ];
    };
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  hardware.keyboard.qmk.enable = true;
}
