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
			brave
			btop
			dejavu_fonts
			gamemode
			gimp-with-plugins
			localsend
			lxmenu-data
			mangohud
			nerd-fonts.jetbrains-mono
			noto-fonts-cjk-sans
			noto-fonts-color-emoji
			obs-studio
			pcmanfm
			prismlauncher
			shared-mime-info
			steam
			swaylock
			tmux
			tree
			unzip
			vesktop
			wl-clipboard
			xdg-desktop-portal-gtk
			xdg-desktop-portal-wlr
			xwayland
			yt-dlp
			zerotierone
			zip
    			mpv
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

	programs.bash.enable = true;
	programs.kitty.enable = true;
	programs.git.enable = true;

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
		};
	};
}
