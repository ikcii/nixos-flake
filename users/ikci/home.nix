{ lib, config, pkgs, ... }: {

  fonts.fontconfig.enable = true;

  nixpkgs.config.allowUnfree = true;

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
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
      xdg-utils
      xdg-user-dirs
      xwayland

      # other

      ani-cli
      cbonsai
      cmatrix
      cowsay
      easyeffects
      fastfetch
      faugus-launcher
      ffmpeg
      figlet
      fortune
      gamemode
      gimp-with-plugins
      git-filter-repo
      libqalculate
      libreoffice-still
      localsend
      lolcat
      mangohud
      nix-index
      nix-search-cli
      nvimpager
      obs-studio
      pcmanfm
      pipes
      prismlauncher
      qalculate-qt
      slurp
      steam
      tree
      unzip
      wget
      wtf
      zerotierone
      zip

      (import (pkgs.fetchFromGitHub {
      	owner = "NixOS";
	repo = "nixpkgs";
	rev = "0ba4d0e96e2358ea1db4737ff8591cba314a574e";
	sha256 = "sha256-A9GqrOD7eISfDCjPRiaB5Tb3njV8zPyG5Y1khd5rJQo=";
      }) {
      	system = pkgs.system;
      }).tome4

    ];

    # pointerCursor = {
    #     			name = "Adwaita";
    #     			package = pkgs.adwaita-icon-theme;
    #     			size = 24;
    #     			x11 = {
    #     				enable = true;
    #     				defaultCursor = "Adwaita";
    #     			};
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
    btop.enable = true;
    btop.package = pkgs.btop-cuda;
    brave.enable = true;
    cava.enable = true;
    feh.enable = true;
    git.enable = true;
    kitty.enable = true;
    neovim.enable = true;
    swaylock.enable = true;
    tmux.enable = true;
    vesktop.enable = true;
    yt-dlp.enable = true;
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

  xdg = {
    portal = {
      enable = true;
      config.common.default = "*";
      extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    };
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  wayland.windowManager.sway = {

    enable = true;
    wrapperFeatures.gtk = true;
    
    # xwayland = true;

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

      bars = [
        config.stylix.targets.sway.exportedBarConfig
      ];
    };
  };

  stylix = {
    enable = true;
    autoEnable = true;
    image = ./wallpaper.png;
    polarity = "dark";
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
  # 	enable = true;
  # 	defaultApplications = {
  # 		"text/html" = "brave.desktop";
  # 		"x-scheme-handler/http" = "brave.desktop";
  # 		"x-scheme-handler/https" = "brave.desktop";
  #    		"x-scheme-handler/about" = "brave.desktop";
  #    		"x-scheme-handler/unknown" = "brave.desktop";
  # 	};
  # };

  services.kanshi = 
  let
    kanshi-script = pkgs.writeShellScriptBin "arrange-workspaces" ''
      #!${pkgs.runtimeShell}

        PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.sway ]}

        sleep 2

        if [[ "$KANSHI_PROFILE" == "docked" ]]; then
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
            name = "laptop";
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
            name = "docked";
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
