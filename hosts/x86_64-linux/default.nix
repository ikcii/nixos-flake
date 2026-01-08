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
}
