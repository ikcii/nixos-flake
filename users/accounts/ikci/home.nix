{ lib, config, pkgs, ... }: {

	fonts.fontconfig.enable = true;
	nixpkgs.config.allowUnfree = true;

	home = {
		sessionVariables = {
			EDITOR = "nvim";
			BROWSER = "brave";
			XDG_SESSION_TYPE = "wayland";
    			XDG_CURRENT_DESKTOP = "sway";
		};

		packages = with pkgs; [
			ani-cli
			brave
			btop
			dejavu_fonts
			gamemode
			nerd-fonts.jetbrains-mono
			noto-fonts-color-emoji
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
			obs-studio
			xdg-desktop-portal-wlr
			xdg-desktop-portal-gtk
			gimp
			gimpPlugins.gmic
			prismlauncher
		];

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

		config = rec {
			input = {
				"*" = {
					xkb_layout = "pl";
				};
			};
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
