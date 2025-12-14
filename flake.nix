{
  description = "My system flake";

  # ================================================================ #
  #                            INPUTS                                #
  # ================================================================ #
  # Inputs are external repositories (dependencies) that we download.
  inputs = {
    # Nixpkgs: The giant repository containing all packages (firefox, git, etc.)
    # and the core NixOS operating system modules.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager: A tool to manage user specific config (dotfiles)
    # separately from the system.
    home-manager = {
      url = "github:nix-community/home-manager";
      # "follows" means: Use the exact same version of nixpkgs as the system does.
      # This prevents downloading nixpkgs twice (saving space and time).
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Stylix: An automated theming tool. It uses your wallpaper to generate
    # color schemes for your entire OS and apps.
    stylix = {
      url = "github:make-42/stylix/matugen";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # MNW: A wrapper that helps manage Neovim configurations within Nix.
    mnw.url = "github:Gerg-L/mnw";

    # Niri: A specific Wayland window manager (compositor).
    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # ================================================================ #
  #                            OUTPUTS                               #
  # ================================================================ #
  # The function that produces the actual system configurations.
  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      # 'lib' is the standard library of Nix. It contains hundreds of utility 
      # functions for processing lists, strings, and files. We import it here 
      # so we don't have to type "nixpkgs.lib" every time we need a helper.
      inherit (nixpkgs) lib;

      # --- Helpers ---

      # Function to find all subdirectories in a given path.
      # usage: listDirs ./users -> [ "john" "jane" ]
      listDirs = path:
        lib.attrNames (lib.filterAttrs (name: type: type == "directory") (builtins.readDir path));

      # --- Data Discovery (Scanning folders) ---

      # 1. FIND SYSTEMS
      # Look inside ./hosts to see which architectures we support.
      # If ./hosts contains "x86_64-linux" and "aarch64-darwin", this list will contain them.
      supportedSystems = listDirs ./hosts;

      # 2. FIND HOSTS
      # Scans ./hosts/<system> to find all actual machines.
      # Returns a list like: [ { hostname = "desktop"; system = "x86_64-linux"; } ... ]
      allHosts = lib.concatMap (system:
        let hostnames = listDirs ./hosts/${system};
        in map (hostname: { inherit system hostname; }) hostnames
      ) supportedSystems;

      # 3. FIND USERS
      # Scans ./users to find all usernames.
      # Returns a list like: [ "ikci" "john" "jane" ]
      allUsers = listDirs ./users;

      # --- Module Configuration ---

      # A list of modules (files/plugins) that *every* user gets.
      # We define this once here to keep the code DRY (Don't Repeat Yourself).
      commonUserModules = [
        inputs.stylix.homeModules.stylix
        inputs.mnw.homeManagerModules.mnw
        inputs.niri-flake.homeModules.niri
      ];

      # --- Builders (The "Recipes") ---

      # 1. System Builder (NixOS)
      mkSystem = { hostname, system }:
        lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; }; # Pass inputs to modules so we can use them there
          modules = [
            # -- Global Configs --
            ./hosts                      # Apply to everyone
            ./hosts/${system}            # Apply to this architecture (e.g. linux specific)

            # -- Machine Specific --
            ./hosts/${system}/${hostname}
            ./hosts/${system}/${hostname}/hardware-configuration.nix

            # -- User Management (Home Manager running inside NixOS) --
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };

              # Loop over all users found in ./users and generate their config
              home-manager.users = lib.genAttrs allUsers (username: {
                imports = [ 
                  # Import the specific user's file (e.g. ./users/john/home.nix)
                  (./users/${username}/home.nix) 
                ] ++ commonUserModules;
              });
            }

            # -- Networking --
            {
              networking.hostName = hostname;
              # Don't let the router override our hostname
              networking.dhcpcd.setHostname = false;
            }
          ];
        };

      # 2. Home Manager Builder (Standalone)
      # This generates a configuration for a specific user on a specific system
      # (e.g. "john" on "x86_64-linux").
      mkHome = { username, system }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit inputs; };
          modules = [
            {
              home.username = username;
              home.homeDirectory = if lib.hasInfix "darwin" system
                then "/Users/${username}" # macOS path
                else "/home/${username}"; # Linux path
            }
            # The user's specific config file
            (./users/${username}/home.nix)
          ] ++ commonUserModules; # Add the shared stuff (stylix, etc)
        };

    in
    {
      # --- Final Output Construction ---

      # 1. NixOS Systems
      # Maps our list of scanned hosts to the `mkSystem` builder.
      # Access via: nixos-rebuild switch --flake .#hostname
      nixosConfigurations = lib.listToAttrs (map (host: {
        name = host.hostname;
        value = mkSystem host;
      }) allHosts);

      # 2. Home Manager Configurations
      # This is split into two parts: Pure and Aliases.
      homeConfigurations =
        let
          # Step A: The "Pure" Configs.
          # We generate a unique config for every user on every system found in ./hosts.
          # Example output keys: "john@x86_64-linux", "john@aarch64-darwin"
          pureConfigs = lib.listToAttrs (lib.concatMap (system:
            map (username: {
              name = "${username}@${system}";
              value = mkHome { inherit username system; };
            }) allUsers
          ) supportedSystems);

          # Step B: The "Impure" Aliases.
          # We create a shortcut based on the machine you are currently running this on.
          # If you run `home-manager switch .#john`, it looks up `builtins.currentSystem`
          # (e.g. x86_64-linux) and points to the matching pure config from Step A.
          aliases = lib.genAttrs allUsers (username: 
            pureConfigs."${username}@${builtins.currentSystem}"
          );
        in
        # Merge them so you can use either the specific name or the shortcut.
        pureConfigs // aliases;
    };
}
