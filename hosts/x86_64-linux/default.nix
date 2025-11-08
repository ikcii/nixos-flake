# Settings for all x86_64-linux systems
{ lib, pkgs, ... }:

{
  # --- Bootloader ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmp.cleanOnBoot = true;
  
  # --- Kernel ---
  # Default to latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # --- Hardware & Drivers ---
  hardware.enableAllFirmware = true;
  hardware.graphics.enable = true;

  # --- Console & Keymaps ---
  console.useXkbConfig = true;
}
