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
		lib = nixpkgs.lib;

		listDirs = path:
			lib.attrNames (lib.filterAttrs (name: type: type == "directory") (builtins.readDir path));

		homeManagerModules =
		let
			usernames = listDirs ./users;
			
			buildUserModules = username: {
				value = [
					inputs.stylix.homeModules.stylix
					./users/${username}/home.nix
				];
				name = username;
			};
		in
		lib.listToAttrs (map  buildUserModules usernames);

		mkSystem = { hostname, system }:
			lib.nixosSystem {
				inherit system;
				specialArgs = { inherit inputs homeManagerModules; };
				modules = [
					./hosts
					./hosts/${system}
					./hosts/${system}/${hostname}
					./hosts/${system}/${hostname}/hardware-configuration.nix

					./users

					home-manager.nixosModules.home-manager

					# My hostname got a stroke once so I keep this as a placebo
					({ ... }: {
						networking.hostName = hostname;
                				networking.dhcpcd.setHostname = false;
              				})
				];
			};

	in
	{
		homeManagerConfigurations = lib.mapAttrs (username: modules:
			home-manager.lib.homeManagerConfiguration {
				pkgs = nixpkgs.legacyPackages.${builtins.currentSystem};
				extraSpecialArgs = { inherit inputs; };
				modules = [
					({ pkgs, ... }: {
						home.username = username;
						home.homeDirectory =
							if pkgs.stdenv.isDarwin
							then "/Users/${username}"
							else "/home/${username}";
					})
				] ++ modules;
			}
		) homeManagerModules;

		nixosConfigurations =
		let
			archs = listDirs ./hosts;
			hostNameValuePairs = lib.concatMap (system:
				let
					hostnames = listDirs ./hosts/${system};
				in
				lib.map (hostname: {
					name = hostname;
					value = mkSystem { inherit hostname system; };
				}) hostnames
			) archs;
		in
		lib.listToAttrs hostNameValuePairs;
	};
}
