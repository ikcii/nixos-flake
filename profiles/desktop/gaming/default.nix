# Gaming
{ pkgs, inputs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
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
