{ lib, config, pkgs, ... }: {

	fonts.fontconfig.enable = true;

	nixpkgs.config.allowUnfree = true;

	home = {
		sessionVariables = {
			BROWSER = "brave";
			EDITOR = "nvim";
			GDK_BACKEND = "x11";
			NIXOS_OZONE_WL = "1";
			XDG_SESSION_TYPE = "wayland";
    			XDG_CURRENT_DESKTOP = "sway";
			NIXPKGS_ALLOW_UNFREE = "1";
		};

		packages = with pkgs; [
			ani-cli
			btop
			cava
			cbonsai
			cmatrix
			cowsay
			dejavu_fonts
			fastfetch
			fortune
			gamemode
			gimp-with-plugins
			libqalculate
			localsend
			lxmenu-data
			mangohud
			nerd-fonts.jetbrains-mono
			noto-fonts-cjk-sans
			noto-fonts-color-emoji
			obs-studio
			pcmanfm
			pipes
			prismlauncher
			qalculate-qt
			shared-mime-info
			steam
			swaylock
			tree
			unzip
			vesktop
			wl-clipboard
			wtf
			xdg-desktop-portal-gtk
			xdg-desktop-portal-wlr
			xwayland
			yt-dlp
			zerotierone
			zip
    			neovim
    			nvimpager
    			wget
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

		stateVersion = "25.05";
	};
	
	programs = {
		bash.enable = true;
		brave.enable = true;
		git.enable = true;
		kitty.enable = true;
		tmux.enable = true;
		mpv = {
			enable = true;
			config = {
				hwdec = "nvdec,nvdec-copy,vaapi,vaapi-copy,auto";
				vo = "gpu";
			};
		};
	};

	xdg.portal = {
		enable = true;
		config.common.default = "*";
		extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
	};

	wayland.windowManager.sway = rec {

		enable = true;
		wrapperFeatures.gtk = true;
		
		xwayland = true;

		config = rec {

			input."*".xkb_layout = "pl";

			modifier = "Mod4";
			terminal = "kitty";

			defaultWorkspace = "workspace number 1";


			keybindings = lib.mkOptionDefault {
				"${modifier}+s" = "scratchpad show";
				"${modifier}+Shift+s" = "move scratchpad";
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
				inner = 1;
				outer = 1;
			};

		};
	};

	stylix = {
		enable = true;
		image = ./wallpaper.png;
		opacity = {
			applications = 0.8;
			popups = 0.8;
			desktop = 0.8;
			terminal = 0.8;
		};
		autoEnable = true;

		fonts.monospace.name = "JetBrainsMono Nerd Font";
	};
}
