# Global settings for ALL systems in this flake
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
  # A low-priority default for any machine that enables an X server.
  services.xserver.xkb = lib.mkDefault {
    layout = "pl";
    variant = "";
  };

  # --- Global Users ---
  users.list = [ "ikci" ];

  # --- Nix Settings ---
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # --- Networking ---
  networking.networkmanager.enable = true;

  # --- Universal System Packages ---
  environment.systemPackages = with pkgs; [
    sl
  ];

  # --- System State ---
  # Leave unchanged, mandatory setting for NixOS, versioning is controlled by flake
  system.stateVersion = "25.05";
}
