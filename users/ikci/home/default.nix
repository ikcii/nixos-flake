{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ../../../modules/home/desktop
    ../../../modules/home/programs
    ../../../modules/home/cli
    ../../../modules/home/editors
    ../../../modules/home/services
  ];

  nixpkgs.overlays = [
    inputs.fjordlauncher.overlays.default
    # Fix openldap test error
    (final: prev: {
      openldap = prev.openldap.overrideAttrs (_: {
        doCheck = false;
      });
    })
  ];

  stylix.image = ./wallpaper.jpg;

  home = {
    packages =
      with pkgs;
      let
        specifyNixpkgs =
          url: sha256:
          (import
            (builtins.fetchTarball {
              inherit url sha256;
            })
            {
              system = pkgs.stdenv.hostPlatform.system;
            }
          );
      in
      [
        (specifyNixpkgs "https://github.com/NixOS/nixpkgs/archive/0ba4d0e96e2358ea1db4737ff8591cba314a574e.tar.gz" "02i5dgg8ar4dwn3grk3w6nggfdp5h4k4dkr81jgq8y7vw2naml83")
        .tome4
      ];

    file = {
      "downloads" = {
        source = config.lib.file.mkOutOfStoreSymlink config.xdg.userDirs.download;
      };
    };

    stateVersion = "25.05";
  };

  xdg.systemDirs.data = [
    "''${config.home.homeDirectory}/.local/share/flatpak/exports/share"
  ];
}
