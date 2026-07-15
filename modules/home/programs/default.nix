{ config, pkgs, ... }:

{
  programs = {
    brave.enable = true;
    cava.enable = true;
    feh.enable = true;
    yt-dlp.enable = true;

    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        obs-vaapi
        obs-vkcapture
        obs-gstreamer
        obs-pipewire-audio-capture
      ];
    };

    sioyek = {
      enable = true;
      config = {
        "startup_view_mode" = "dark_mode";
      };
    };

    vesktop = {
      enable = true;

      vencord.settings = {
        autoUpdate = false;
        autoUpdateNotification = false;
        notifyAboutUpdates = false;

        useQuickCss = false;
        disableMinSize = true;
        plugins = {
          ImageFilename.enabled = true;
          petpet.enabled = true;
          GifPaste.enabled = true;
          VolumeBooster.enabled = true;
          FakeNitro.enabled = true;
          ViewRaw.enabled = true;
          MessageLogger = {
            enabled = true;
            ignoreSelf = true;
          };
          ViewIcons = {
            enabled = true;
            format = "png";
            imgSize = "4096";
          };
          PermissionFreeWill.enabled = true;
          PermissionsViewer.enabled = true;
        };
      };

      settings = {
        checkUpdates = false;
        discordBranch = "stable";

        hardwareAcceleration = true;
        videoHardwareAcceleration = true;
        minimizeToTray = false;
        splashTheming = true;
        spellCheckLanguages = [
          "en"
          "en-US"
          "pl"
        ];
      };
    };

    mpv = {
      enable = true;
      config = {
        # system specific
        gpu-context = "wayland";

        # general
        hwdec = "auto-safe";
        vo = "gpu";
      };
    };
  };

  home.packages = with pkgs; [
    (bottles.override { removeWarningPopup = true; })
    faugus-launcher
    fjordlauncher
    gimp-with-plugins
    localsend
    protontricks
    qalculate-qt
    scrcpy
    zerotierone
  ];
}
