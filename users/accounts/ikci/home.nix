{ lib, config, pkgs, ... }: {

	fonts.fontconfig.enable = true;
	nixpkgs.config.allowUnfree = true;

	home = {
		sessionVariables = {
			EDITOR = "nvim";
		};

		packages = with pkgs; [
			ani-cli
			brave
			btop
			dejavu_fonts
			gamemode
			nerd-fonts.jetbrains-mono
			noto-fonts-color-emoji
			steam
			swaylock
			tmux
			tree
			vesktop
			wl-clipboard
			zerotierone
		];

		stateVersion = "25.05";
	};

	programs.bash.enable = true;
	programs.kitty.enable = true;
	programs.git.enable = true;

	wayland.windowManager.sway = rec {

		enable = true;
		wrapperFeatures.gtk = true;

		config = rec {
			modifier = "Mod4";
			terminal = "kitty";
			defaultWorkspace = "workspace number 1";

			keybindings = lib.mkOptionDefault {
				"${modifier}+s" = "scratchpad show";
				"${modifier}+Shift+s" = "move scratchpad";
			};
		};
	};
}
