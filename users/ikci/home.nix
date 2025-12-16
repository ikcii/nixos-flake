{ lib, config, pkgs, ... }: {

  fonts.fontconfig.enable = true;

  home = {
    sessionVariables = {

      # universal

      BROWSER = "brave";
      EDITOR = "nvim";
      NIXPKGS_ALLOW_UNFREE = "1";

      # current system

      GDK_BACKEND = "wayland,x11";
      NIXOS_OZONE_WL = "1";
      XDG_SESSION_TYPE = "wayland";
      XDG_CURRENT_DESKTOP = "sway";
      SDL_VIDEODRIVER = "wayland,x11,windows";
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
      _JAVA_AWT_WM_NONREPARENTING = 1;

    };

    packages = with pkgs; [

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

      # other

      android-tools
      ani-cli
      bat
      bottles
      cbonsai
      cmatrix
      cowsay
      easyeffects
      fastfetch
      faugus-launcher
      fd
      ffmpeg
      figlet
      file
      fortune
      fuse-overlayfs
      fzf
      gamemode
      gimp-with-plugins
      git-filter-repo
      htop
      libqalculate
      libreoffice-still
      localsend
      lolcat
      nh
      nix-index
      nix-search-cli
      nvimpager
      obs-studio
      p7zip-rar
      pcmanfm
      pipes
      prismlauncher
      pulseaudio
      python3
      qalculate-qt
      qdirstat
      ripgrep
      slurp
      steam
      tealdeer
      tokei
      tome4
      tree
      tree-sitter
      unzip
      wget
      wtf
      zerotierone
      zip

      # (import (pkgs.fetchFromGitHub {
      #   owner = "NixOS";
      #   repo = "nixpkgs";
      #   rev = "0ba4d0e96e2358ea1db4737ff8591cba314a574e";
      #   sha256 = "sha256-A9GqrOD7eISfDCjPRiaB5Tb3njV8zPyG5Y1khd5rJQo=";
      # }) {
      #   system = pkgs.system;
      # }).tome4

      # (cataclysm-dda-git.overrideAttrs (old: {
      #   tag = null;
      #   rev = "9afa12b497ca332919c3fdde840df75a15b8da3f";
      #   hash = "";
      # }))

    ];

    # pointerCursor = {
    #           name = "Adwaita";
    #           package = pkgs.adwaita-icon-theme;
    #           size = 24;
    #           x11 = {
    #             enable = true;
    #             defaultCursor = "Adwaita";
    #           };
    # };

    file = {
      "downloads" = {
        source = config.lib.file.mkOutOfStoreSymlink config.xdg.userDirs.download;
      };
    };

    stateVersion = "25.05";
  };

  programs = {

    bash.enable = true;
    brave.enable = true;
    cava.enable = true;
    feh.enable = true;
    git.enable = true;
    swaylock.enable = true;
    yt-dlp.enable = true;
    zoxide.enable = true;

    vesktop = {
      enable = true;
      vencord.settings = {
        autoUpdateNotification = true;
        notifyAboutUpdates = true;
        useQuickCss = false;
        disableMinSize = true;
        plugins = {
          VolumeBooster.enabled = true;
          FakeNitro.enabled = true;
          MessageLogger = {
            enabled = true;
            ignoreSelf = true;
          };
        };
      };
    };

    btop = {
      enable = true;
      package = pkgs.btop-rocm;
      settings = lib.mkOptionDefault {
        proc_sorting = "pid";
        proc_reversed = true;
        proc_tree = true;
        shown_boxes = "proc cpu mem net gpu0";
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

    mangohud = {
      enable = true;
      settings = lib.mkOptionDefault {
        gpu_temp = true;
        cpu_temp = true;
        throttling_status = true;
      };
    };

    mnw = {
      enable = true;
      neovim = pkgs.neovim-unwrapped;

      luaFiles = [ ./nvim/init.lua ];

      plugins = {

        start = with pkgs.vimPlugins; [
          lazy-nvim
        ];

        opt = with pkgs.vimPlugins; [
          nvim-treesitter
          plenary-nvim
          telescope-nvim
          which-key-nvim
          mini-icons
          nvim-web-devicons
        ] ++ (with nvim-treesitter-parsers; [
          bash
          css
          html
          java
          javadoc
          javascript
          luadoc
          luap
          nix
          python
        ]);

        dev.config = {
          pure = ./nvim;
        };
      };
    };

    tmux = { 
      enable = true;
      mouse = true;
      focusEvents = true;
      escapeTime = 100;
      terminal = "screen-256color";
    };

    kitty = {
      enable = true;
      settings = {
        confirm_os_window_close = 0;
        shell = "sh -c \"tmux has-session -t main 2>/dev/null && exec tmux new-session -t main \\\\; new-window || exec tmux new-session -s main \\\"ssh-agent $SHELL\\\"\"";
      };
    };

    niri = {
      enable = true;
      package = pkgs.niri;
    };
  };

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
      extraPortals =  with pkgs; [ xdg-desktop-portal-wlr xdg-desktop-portal-gtk ];
    };
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  wayland.windowManager.sway = {

    enable = true;

    wrapperFeatures.gtk = true;

    config = rec {

      input."*".xkb_layout = "pl";

      modifier = "Mod4";
      terminal = "kitty";

      keybindings = lib.mkOptionDefault {
        "${modifier}+s" = "scratchpad show";
        "${modifier}+Shift+s" = "move scratchpad";
        "${modifier}+p" = "exec grim -g \"$(slurp)\" - | wl-copy";
        "${modifier}+o" = "exec swaylock";
        "${modifier}+Shift+o" = "exec swaylock & systemctl sleep";
        "${modifier}+Shift+c" = "exec swaymsg reload && kanshictl reload";
        "XF86MonBrightnessDown" = "exec light -U 10";
        "XF86MonBrightnessUp" = "exec light -A 10";
        "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
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
    };
  };

  stylix = {
    enable = true;
    autoEnable = true;
    image = ./wallpaper.png;
    colorGeneration.polarity = "dark";
    colorGeneration.scheme = "vibrant";
    opacity = {
      applications = 0.8;
      popups = 0.8;
      desktop = 0.8;
      terminal = 0.8;
    };

    fonts.monospace.name = "JetBrainsMono Nerd Font";

    targets.cava.rainbow.enable = true;
  };

  # xdg.mimeApps = {
  #   enable = true;
  #   defaultApplications = {
  #     "text/html" = "brave.desktop";
  #     "x-scheme-handler/http" = "brave.desktop";
  #     "x-scheme-handler/https" = "brave.desktop";
  #       "x-scheme-handler/about" = "brave.desktop";
  #       "x-scheme-handler/unknown" = "brave.desktop";
  #   };
  # };

  services.easyeffects.enable = true;

  services.kanshi = 
  let
    kanshi-script = pkgs.writeShellScriptBin "arrange-workspaces" ''
      #!${pkgs.runtimeShell}

        PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.sway ]}

        sleep 2

        if [[ "$KANSHI_PROFILE" == "laptop-docked" ]]; then
          ${pkgs.sway}/bin/swaymsg 'workspace number 1, move workspace to output HDMI-A-2'
          ${pkgs.sway}/bin/swaymsg 'workspace number 2, move workspace to output eDP-1'
          ${pkgs.sway}/bin/swaymsg 'workspace number 1'
        fi
    '';
  in
  {
    enable = true;
    settings = [
      {
        profile = {
          name = "desktop-default";
          outputs = [
            {
              criteria = "HDMI-A-1";
              status = "enable";
              mode = "1920x1080@120.040Hz";
              transform = "90";
              position = "0,0";
            }
            {
              criteria = "DP-1";
              status = "enable";
              mode = "2560x1440@179.960Hz";
              position = "1080,550";
            }
          ];
          exec = "${kanshi-script}/bin/arrange-workspaces";
        };
      }
      {
        profile = {
          name = "laptop-default";
          outputs = [
            {
              criteria = "eDP-1";
              status = "enable";
              mode = "1920x1080@60.052Hz";
              position = "0,0";
            }
          ];
          exec = "${kanshi-script}/bin/arrange-workspaces";
        };
      }
      {
        profile = {
          name = "laptop-docked";
          outputs = [
            {
              criteria = "eDP-1";
              status = "enable";
              mode = "1920x1080@60.052Hz";
              position = "2560,360";
            }
            {
              criteria = "HDMI-A-2";
              status = "enable";
              mode = "2560x1440@59.951Hz";
              position = "0,0";
            }
          ];
          exec = "${kanshi-script}/bin/arrange-workspaces";
        };
      }
    ];
  };
}
