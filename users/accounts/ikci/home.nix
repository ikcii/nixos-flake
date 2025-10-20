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
			cbonsai
			cmatrix
			cowsay
			dejavu_fonts
			fastfetch
			ffmpeg
			figlet
			fortune
			gamemode
			gimp-with-plugins
			grim
			libqalculate
			localsend
			lolcat
			lxmenu-data
			mangohud
			nerd-fonts.jetbrains-mono
			noto-fonts
			noto-fonts-cjk-sans
			noto-fonts-color-emoji
			obs-studio
			pcmanfm
			pipes
			prismlauncher
			qalculate-qt
			shared-mime-info
			slurp
			steam
			tree
			unzip
			wl-clipboard
			wtf
			xdg-desktop-portal-gtk
			xdg-desktop-portal-wlr
			xdg-utils
			xwayland
			zerotierone
			zip
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
		btop.enable = true;
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

	wayland.windowManager.sway = {

		enable = true;
		wrapperFeatures.gtk = true;
		
		# xwayland = true;

		config = rec {

			input."*".xkb_layout = "pl";

			modifier = "Mod4";
			terminal = "kitty";

			defaultWorkspace = "workspace number 1";


			keybindings = lib.mkOptionDefault {
				"${modifier}+s" = "scratchpad show";
				"${modifier}+Shift+s" = "move scratchpad";
				"${modifier}+p" = "exec grim -g \"$(slurp)\" - | wl-copy";
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
}
