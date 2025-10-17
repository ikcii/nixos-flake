{ lib, config, pkgs, ... }: {

	fonts.fontconfig.enable = true;
	nixpkgs.config.allowUnfree = true;

	home = {
		sessionVariables = {
			EDITOR = "nvim";
		};

		packages = with pkgs; [
			dejavu_fonts
			brave
			btop
			swaylock
			nerd-fonts.jetbrains-mono
			tmux
			tree
			wl-clipboard
			vesktop
			gamemode
			steam
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
