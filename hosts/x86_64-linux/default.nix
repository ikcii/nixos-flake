# Settings for all x86_64-linux systems
{ lib, pkgs, ... }:

{
  imports = [
    ../../modules/nixos/services
  ];

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
  # Default to latest kernel
  boot.kernelPackages = lib.mkDefault pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto;

  # Hardware & Drivers
  hardware.enableAllFirmware = true;
  hardware.graphics.enable = true;

  # x86_64-linux Packages
  environment.systemPackages = with pkgs; [
    activate-linux
  ];

  # zram
  zramSwap.enable = true;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  hardware.keyboard.qmk.enable = true;
}
