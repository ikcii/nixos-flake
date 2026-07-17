{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
{
  fonts.fontconfig.enable = true;

  nixpkgs.overlays = [
    inputs.fjordlauncher.overlays.default
    # Fix openldap test error
    (final: prev: {
      openldap = prev.openldap.overrideAttrs (_: {
        doCheck = false;
      });
    })
  ];

  home = {
    sessionVariables = {

      # universal

      BROWSER = "brave";
      EDITOR = "nvim";
      NIXPKGS_ALLOW_UNFREE = "1";

      # current system

      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      GDK_BACKEND = "wayland,x11";
      NIXOS_OZONE_WL = "1";
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
      SDL_VIDEODRIVER = "wayland,x11,windows";
      XDG_CURRENT_DESKTOP = "sway";
      XDG_SESSION_TYPE = "wayland";
      _JAVA_AWT_WM_NONREPARENTING = 1;

      WINEDLLOVERRIDES = "winhttp=n,b;version=n,b";

    };

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

        # LLM file context utility
        (pkgs.writeShellScriptBin "ct" "for file in \"$@\"; do echo \"$file\"; echo '```'; cat \"$file\"; echo; echo '```'; done")

        # --user only flatpak
        (pkgs.writeShellScriptBin "flatpak" ''
          exec ${lib.getExe pkgs.flatpak} --user "$@"
        '')

        # general

        # logseq
        #libreoffice-still
        android-tools
        ani-cli
        audiosource
        bat
        brightnessctl
        cbonsai
        cmatrix
        compsize
        cowsay
        dotnetCorePackages.sdk_10_0
        dust
        easyeffects
        espeak
        fastfetch
        faugus-launcher
        fd
        ffmpeg
        figlet
        file
        fjordlauncher
        fortune
        fuse-overlayfs
        fzf
        gale
        gamemode
        gimp-with-plugins
        git-filter-repo
        htop
        killall
        lazygit
        libqalculate
        localsend
        lolcat
        nh
        nix-index
        nix-search-cli
        nixfmt
        nodejs
        nvimpager
        p7zip-rar
        pcmanfm
        pipes
        protege-distribution
        protontricks
        python3
        qalculate-qt
        qdirstat
        recoll
        ripgrep
        scrcpy
        slurp
        tealdeer
        tokei
        tree
        tree-sitter
        unityhub
        unzip
        uv
        wdisplays
        wget
        wtf
        zerotierone
        zip

        (haskellPackages.ghcWithPackages (
          p: with p; [
            shh
            shh-extras
          ]
        ))

        # LSPs

        bash-language-server
        csharp-ls
        haskell-language-server
        lua-language-server
        nil
        pyright

        # overrides, etc

        (specifyNixpkgs "https://github.com/NixOS/nixpkgs/archive/0ba4d0e96e2358ea1db4737ff8591cba314a574e.tar.gz" "02i5dgg8ar4dwn3grk3w6nggfdp5h4k4dkr81jgq8y7vw2naml83")
        .tome4

        # (import (builtins.fetchTarball {
        #   url = "https://github.com/NixOS/nixpkgs/archive/52047c30129eb1bd860a5549f2b2b2d61e0dbfbc.tar.gz";
        #   sha256 = "0hkhwd703z6xcqqxxj9krkn6c0p5lhfi7q471yccv78xkglv0gxy";
        # }) {
        #   system = pkgs.system;
        #   config.rocmSupport = true;
        # }).vllm

        # (
        #   (cataclysm-dda-git.override {
        #     rev = "c62165965c6b74c291c5201cabc3a6e0f385afec";
        #     sha256 = "sha256-+scyPpsGpW7eMPxvmgIxCtpp0njqZZn/CrbhyrP7c7s=";
        #     version = "2026-03-15";
        #   }).overrideAttrs
        #   (old: {
        #     env = (old.env or { }) // {
        #       NIX_CFLAGS_COMPILE = (old.env.NIX_CFLAGS_COMPILE or "") + " -Wno-error=free-nonheap-object";
        #     };
        #   })
        # )

        (llama-cpp-rocm.overrideAttrs (old: rec {
          version = "9591";
          src = old.src.override {
            owner = "PrismML-Eng";
            repo = "llama.cpp";
            tag = null;
            rev = "62061f91088281e65071cc38c5f69ee95c39f14e";
            hash = "sha256-zLxB5UKnCTCw/okB+L8u1VtM1o2yVjVYTlTBgL/BsaM=";
          };
          npmDepsHash = "sha256-pjdbI6NcZRlJVd62xhgbLhWrwFYwgsIwjORqvo1+VD8=";
          npmRoot = "tools/ui";
        }))

      ];

    # cursor theming

    # pointerCursor = {
    #           name = "Adwaita";
    #           package = pkgs.adwaita-icon-theme;
    #           size = 24;
    #           x11 = {
    #             enable = true;
    #             defaultCursor = "Adwaita";
    #           };
    # };

    # we're saving up 0.01ms of having to hold shift while typing downloads once a week

    file = {
      "downloads" = {
        source = config.lib.file.mkOutOfStoreSymlink config.xdg.userDirs.download;
      };
    };

    stateVersion = "25.05";
  };

  programs = {

    brave.enable = true;
    cava.enable = true;
    feh.enable = true;
    git.enable = true;
    swaylock.enable = true;
    yt-dlp.enable = true;

    emacs = {
      enable = true;
      extraPackages = epkgs: [
        epkgs.evil
        epkgs.corfu
        epkgs.vertico
      ];
    };

    rofi = {
      enable = true;
      extraConfig = {
        drun-match-fields = "name";
      };
    };

    obs-studio = {
      enable = true;

      plugins = with pkgs.obs-studio-plugins; [
        obs-vaapi
        obs-vkcapture
        obs-gstreamer
        obs-pipewire-audio-capture
      ];
    };

    zoxide = {
      enable = true;
      enableBashIntegration = true;
      options = [ "--cmd cd" ];
    };

    bash.enable = true;
    readline = {
      enable = true;
      variables = {
        "editing-mode" = "vi";
      };
    };

    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
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

    btop = {
      enable = true;
      settings = {
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
      settings = {
        gpu_temp = true;
        cpu_temp = true;
        throttling_status = true;
        fps_limit = 180;
        fps_limit_method = "late";
      };
    };

    mnw =
      let
        onlyColorStrings = lib.filterAttrs (
          name: value: builtins.isString value && lib.hasPrefix "base" name
        ) config.lib.stylix.colors;

        stylixLuaColors = lib.concatStringsSep "\n" (
          lib.mapAttrsToList (name: value: "  [\"${name}\"] = \"#${value}\",") onlyColorStrings
        );

        stylix-nvim-theme = pkgs.writeText "stylix-theme.lua" ''
          local colors = {
            ${stylixLuaColors}
          }

          require('base16-colorscheme').setup(colors)

          if ${toString config.stylix.opacity.applications} < 1 then
            vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
            vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
          end
        '';
      in
      {
        enable = true;
        neovim = pkgs.neovim-unwrapped;

        luaFiles = [
          ./nvim/init.lua
          stylix-nvim-theme
        ];

        plugins = {

          start = with pkgs.vimPlugins; [
            lazy-nvim
          ];

          opt =
            let
              pluginDir = ./nvim/lua/plugins;

              pluginFiles = builtins.attrNames (builtins.readDir pluginDir);

              pluginNames = map (lib.removeSuffix ".lua") (lib.filter (x: lib.hasSuffix ".lua" x) pluginFiles);

              autoPlugins = map (name: pkgs.vimPlugins.${name}) pluginNames;
            in
            autoPlugins ++ [ pkgs.vimPlugins.nvim-treesitter.withAllGrammars ];

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
      quickAccessTerminalConfig = {
        edge = "center-sized";
      };
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
        "${modifier}+Ctrl+o" =
          "exec pkill -x ${builtins.baseNameOf (lib.getExe pkgs.activate-linux)} || ${lib.getExe pkgs.activate-linux}";
        "XF86MonBrightnessDown" = "exec brightnessctl s 10%-";
        "XF86MonBrightnessUp" = "exec brightnessctl s +10%";
        "XF86AudioRaiseVolume" =
          "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ && wpctl set-mute @DEFAULT_AUDIO_SINK@ 0";
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

  stylix = {
    enable = true;
    autoEnable = true;
    image = ./wallpaper.jpg;
    colorGeneration.scheme = "vibrant";
    colorGeneration.polarity = "dark";
    #polarity = "dark";
    opacity = {
      applications = 0.8;
      popups = 0.8;
      desktop = 0.8;
      terminal = 0.8;
    };

    fonts.monospace.name = "JetBrainsMono Nerd Font";

    targets.cava.rainbow.enable = true;
  };

  # xdg.desktopEntries.kitty-open-dir = {
  #   name = "Open Directory in Kitty";
  #   exec = "kitty -d %F";
  #   terminal = false;
  #   mimeType = [ "inode/directory" ];
  # };

  xdg.mime.enable = true;
  xdg.mimeApps = {
    enable = true;
    # defaultApplications = {
    #   "inode/directory" = "kitty-open-dir.desktop";
    #   "text/html" = "brave.desktop";
    #   "x-scheme-handler/http" = "brave.desktop";
    #   "x-scheme-handler/https" = "brave.desktop";
    #     "x-scheme-handler/about" = "brave.desktop";
    #     "x-scheme-handler/unknown" = "brave.desktop";
    # };
  };

  xdg.userDirs.setSessionVariables = false;

  xdg.systemDirs.data = [
    "${config.home.homeDirectory}/.local/share/flatpak/exports/share"
  ];

  services = {

    easyeffects.enable = true;

    swayidle = {
      enable = true;
      events = {
        before-sleep = "${pkgs.swaylock}/bin/swaylock -f";
        after-resume = "sleep 1; ${pkgs.sway}/bin/swaymsg 'output * power off'; sleep 2; ${pkgs.sway}/bin/swaymsg 'output * power on'; ${pkgs.kanshi}/bin/kanshictl reload";
      };
    };

    kanshi = {
      enable = true;
      settings = [
        {
          profile = {
            name = "desktop-default";
            outputs = [
              {
                criteria = "LG Electronics 27GK750F 0x0004F6EE";
                status = "enable";
                mode = "1920x1080@120.040Hz";
                transform = "90";
                position = "0,0";
              }
              {
                criteria = "LG Electronics LG ULTRAGEAR 309MAPNFF848";
                status = "enable";
                mode = "2560x1440@179.960Hz";
                position = "1080,550";
              }
            ];
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
          };
        }
      ];
    };
    recoll = {
      enable = true;
    };
  };

  gtk.gtk4.theme = config.gtk.theme;
}
