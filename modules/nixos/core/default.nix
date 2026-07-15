{ lib, pkgs, ... }:

{
  # --- Time & Localization ---
  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pl_PL.UTF-8";
    LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT = "pl_PL.UTF-8";
    LC_MONETARY = "pl_PL.UTF-8";
    LC_NAME = "pl_PL.UTF-8";
    LC_NUMERIC = "pl_PL.UTF-8";
    LC_PAPER = "pl_PL.UTF-8";
    LC_TELEPHONE = "pl_PL.UTF-8";
    LC_TIME = "pl_PL.UTF-8";
  };

  # --- System-Wide Default Keyboard Layout ---
  services.xserver.xkb = lib.mkDefault {
    layout = "pl";
    variant = "";
  };
  console.useXkbConfig = true;

  # --- Nix Settings ---
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    auto-optimise-store = true;
    keep-outputs = true;
    keep-derivations = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 21d";
  };

  # --- Networking ---
  networking.networkmanager.enable = true;

  # --- Universal System Packages ---
  environment.systemPackages = with pkgs; [
    sl
  ];

  # --- home-manager compatibility --
  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
    "/share/bash-completion"
  ];

  # --- System State ---
  system.stateVersion = "25.05";
}
