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
			nerd-fonts.jetbrains-mono
			noto-fonts-color-emoji
			localsend
			noto-fonts-cjk-sans
			steam
			swaylock
			tmux
			tree
			vesktop
			wl-clipboard
			zerotierone
			zip
			unzip
			mangohud
			pcmanfm
			obs-studio
			xdg-desktop-portal-wlr
			xdg-desktop-portal-gtk
			gimp-with-plugins
			prismlauncher
			xwayland
			lxmenu-data
			shared-mime-info
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
