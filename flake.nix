{
	description = "My system flake";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
    };

		stylix = {
			url = "github:danth/stylix";
			inputs.nixpkgs.follows = "nixpkgs";
		};
  };

	outputs = { self, nixpkgs, home-manager, stylix, ... }@inputs: 
		let
			myHosts = {
				"v4real" = { system = "x86_64-linux"; };
			};
			mkSystem = { hostname, system, ... }:
				nixpkgs.lib.nixosSystem {
					inherit system;
      		specialArgs = { inherit inputs; };
      			modules = [
							# Basic hostname setup
							({ ... }: {
								networking.hostName = hostname;
								networking.dhcpcd.setHostname = false;
							})

							# --- REFACTORED MODULE IMPORTS ---
							# 1. Import the module that defines our custom `users.list` option
							./users/modules/options.nix

							# 2. Import configurations that populate the `users.list`
      				./hosts/common/default.nix
							./hosts/${hostname}/hardware-configuration.nix
							# The optional import for the host-specific default.nix is at the end

							# 3. Import the central module that consumes the final `users.list`
							./users/module.nix
							# ------------------------------------

							# Import Home Manager itself
							home-manager.nixosModules.home-manager

      			] ++ (nixpkgs.lib.optional (builtins.pathExists ./hosts/${hostname}/default.nix) ./hosts/${hostname}/default.nix);
			};
		in
		{
			nixosConfigurations = nixpkgs.lib.mapAttrs (hostname: config: mkSystem (config // { inherit hostname; })) myHosts;
		};
}