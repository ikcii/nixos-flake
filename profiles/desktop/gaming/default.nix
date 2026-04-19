# Gaming
{ pkgs, ... }:

{
  boot.kernelPackages = with pkgs; linuxPackagesFor linuxPackages_cachyos;
  programs.steam = {
    enable = true;
    extraCompatPackages = [
      pkgs.proton-ge-bin
      inputs.dw-proton.packages.${pkgs.stdenv.hostPlatform.system}.dw-proton
    ];
  };
  programs.gamemode.enable = true;
  programs.gamescope.enable = true;
}
