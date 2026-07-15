{ config, pkgs, lib, ... }:

{
  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    GDK_BACKEND = "wayland,x11";
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
    SDL_VIDEODRIVER = "wayland,x11,windows";
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_TYPE = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = 1;
    WINEDLLOVERRIDES = "winhttp=n,b";
  };

  home.packages = with pkgs; [
    # fonts
    dejavu_fonts
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji

    # current system daemons utils
    grim
    lxmenu-data
    shared-mime-info
    wl-clipboard
    xdg-utils
    xdg-user-dirs
    xrandr
    xwayland
    slurp
    wdisplays
  ];

  xdg = {
    portal = {
      enable = true;
      xdgOpenUsePortal = true;
      config.sway = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.Screenshot" = "wlr";
        "org.freedesktop.impl.portal.ScreenCast" = "wlr";
        "org.freedesktop.impl.portal.Inhibit" = "none";
      };
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
    };
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  xdg.userDirs.setSessionVariables = false;

  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    config = rec {
      input."*".xkb_layout = "pl";
      modifier = "Mod4";
      terminal = "kitty";
      menu = "rofi -show combi -combi-modes 'drun,run' -modes 'combi' -show-icons";

      keybindings = lib.mkOptionDefault {
        "${modifier}+s" = "scratchpad show";
        "${modifier}+Shift+s" = "move scratchpad";
        "${modifier}+p" = "exec grim -g \"$(slurp)\" - | wl-copy";
        "${modifier}+o" = "exec swaylock";
        "${modifier}+Shift+o" = "exec systemctl sleep";
        "${modifier}+Shift+c" = "exec swaymsg reload && ${pkgs.kanshi}/bin/kanshictl reload";
        "${modifier}+Ctrl+o" = "exec pkill -x ${builtins.baseNameOf (lib.getExe pkgs.activate-linux)} || ${lib.getExe pkgs.activate-linux}";
        "XF86MonBrightnessDown" = "exec brightnessctl s 10%-";
        "XF86MonBrightnessUp" = "exec brightnessctl s +10%";
        "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ && wpctl set-mute @DEFAULT_AUDIO_SINK@ 0";
        "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      };

      window = {
        border = 0;
        titlebar = false;
      };

      gaps = {
        inner = 2;
      };

      startup = [
        {
          command = "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_DATA_DIRS PATH";
          always = false;
        }
        {
          command = "${pkgs.kanshi}/bin/kanshictl reload";
          always = true;
        }
      ];

      workspaceOutputAssign = [
        {
          workspace = "1";
          output = "LG Electronics LG ULTRAGEAR 309MAPNFF848";
        }
        {
          workspace = "2";
          output = "LG Electronics 27GK750F 0x0004F6EE";
        }
        {
          workspace = "1";
          output = "eDP-1";
        }
      ];
    };
  };

  programs.rofi = {
    enable = true;
    extraConfig = {
      drun-match-fields = "name";
    };
  };

  programs.swaylock.enable = true;

  stylix = {
    enable = true;
    autoEnable = true;
    colorGeneration.scheme = "vibrant";
    colorGeneration.polarity = "dark";
    opacity = {
      applications = 0.8;
      popups = 0.8;
      desktop = 0.8;
      terminal = 0.8;
    };
    fonts.monospace.name = "JetBrainsMono Nerd Font";
    targets.cava.rainbow.enable = true;
  };

  gtk.gtk4.theme = config.gtk.theme;
}
