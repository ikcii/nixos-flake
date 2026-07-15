# Global settings for ALL systems in this flake
{ lib, pkgs, ... }:

{
  imports = [
    ../modules/nixos/core
  ];

  # --- Global Users ---
  users.list = [ "ikci" ];
}
