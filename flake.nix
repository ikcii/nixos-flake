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
      inherit (nixpkgs) lib;

      # --- Helpers & Data Discovery ---

      # Helper: Find all subdirectories in a given path.
      listDirs = path:
        lib.attrNames (lib.filterAttrs (name: type: type == "directory") (builtins.readDir path));

      # 1. Supported Architectures
      # Look inside ./hosts to see which architectures we support (e.g., x86_64-linux).
      supportedSystems = listDirs ./hosts;

      # 2. Host Discovery
      # Scans ./hosts/<system> to find all actual machines.
      # Returns: [ { hostname = "desktop"; system = "x86_64-linux"; } ... ]
      allHosts = lib.concatMap (system:
        map (hostname: { inherit system hostname; }) (listDirs ./hosts/${system})
      ) supportedSystems;

      # --- Shared Configuration ---

      # A list of modules that every user gets (mostly from inputs).
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
          # Pass 'inputs' and 'commonUserModules' so they can be used in users/default.nix
          specialArgs = { inherit inputs commonUserModules; };
          modules = [
            # -- Global & Machine Configs --
            ./hosts
            ./hosts/${system}
            ./hosts/${system}/${hostname}
            ./hosts/${system}/${hostname}/hardware-configuration.nix

            # -- User Logic --
            # Handles creating OS users and hooking up Home Manager
            ./users/default.nix

            # -- Home Manager Setup --
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = false;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }

            # -- Networking --
            {
              networking.hostName = hostname;
              networking.dhcpcd.setHostname = false;
            }
          ];
        };

      # 2. Home Manager Builder
      # Generates a configuration for a specific user on a specific system
      # without a full NixOS environment.
      mkHome = { username, system }:
        home-manager.lib.homeManagerConfiguration {
          # Instantiate pkgs explicitly with config. This allows standalone users
          # to use unfree packages even though we removed 'nixpkgs' from home.nix.
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          extraSpecialArgs = { inherit inputs; };
          modules = [
            {
              home.username = username;
              # Homedir paths for darwin vs linux
              home.homeDirectory = if lib.hasInfix "darwin" system
                then "/Users/${username}"
                else "/home/${username}";
            }
            # The user's specific config file
            (./users/${username}/home.nix)
          ] ++ commonUserModules;
        };

    in
    {
      # --- Final Output Construction ---

      # 1. NixOS Systems
      # Access via: nixos-rebuild switch --flake .#hostname
      nixosConfigurations = lib.listToAttrs (map (host: {
        name = host.hostname;
        value = mkSystem host;
      }) allHosts);

      # 2. Home Manager Configurations
      # Access via: home-manager switch --flake .#username
      homeConfigurations =
        let
          allUsers = listDirs ./users;

          # Generate "Pure" configs (e.g., "ikci@x86_64-linux")
          pureConfigs = lib.listToAttrs (lib.concatMap (system:
            map (username: {
              name = "${username}@${system}";
              value = mkHome { inherit username system; };
            }) allUsers
          ) supportedSystems);

          # Generate "Alias" configs (e.g., "ikci") based on current system
          aliases = lib.genAttrs allUsers (username: 
            pureConfigs."${username}@${builtins.currentSystem}"
          );
        in
        pureConfigs // aliases;
    };
}
