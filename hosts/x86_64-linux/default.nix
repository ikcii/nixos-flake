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

  services.zerotierone.enable = true;

  # --- Encrypted DNS ---
  networking = {
    networkmanager.dns = "systemd-resolved";
  };
  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNS = [
        "194.242.2.4#base.dns.mullvad.net"
        "2a07:e340::4#base.dns.mullvad.net"
      ];
      DNSOverTLS = true;
      Domains = [ "~." ];
    };
  };
}
