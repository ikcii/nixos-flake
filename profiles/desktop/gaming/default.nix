# Gaming
{ pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_zen;
  programs.steam = {
    enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };
  programs.gamemode.enable = true;
  programs.gamescope.enable = true;
}
