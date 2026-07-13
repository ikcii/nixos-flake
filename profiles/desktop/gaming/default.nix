# Gaming
{ pkgs, inputs, ... }:

{
  programs.steam = {
    enable = true;
    extraCompatPackages = [
      pkgs.proton-ge-bin
      # inputs.dw-proton.packages.${pkgs.stdenv.hostPlatform.system}.dw-proton
    ];
  };
  programs.gamemode.enable = true;
  programs.gamescope.enable = true;
  services.wivrn = {
    enable = true;
    openFirewall = true;
  };
  environment.systemPackages = with pkgs; [
    wayvr
    opencomposite
    android-tools
  ];
}
