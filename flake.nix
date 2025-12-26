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
              home-manager.useUserPackages = false;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }

            # -- Paranoid Fix For That One Time My Hostname Got Reset And It Broke My System --
            {
              networking.hostName = hostname;
              networking.dhcpcd.setHostname = false;
            }
          ];
        };

      # Special GPU types supported by btop and other hardware-aware packages.
      specialGpus = [ "rocm" "cuda" ];

      # 2. Home Manager Builder
      # Generates a configuration for a specific user on a specific system
      # without a full NixOS environment.
      mkHome = { username, system, gpu ? null }:
        home-manager.lib.homeManagerConfiguration {
          # Instantiate pkgs explicitly with hardware-specific flags.
          pkgs = import nixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
              rocmSupport = (gpu == "rocm");
              cudaSupport = (gpu == "cuda");
            };
          };
          extraSpecialArgs = { inherit inputs; };
          modules = [
            {
              home.username = username;
              # Homedir paths for darwin vs linux
              home.homeDirectory = if lib.hasInfix "darwin" system
                then "/Users/${username}"
                else "/home/${username}";

              # -- Hardware Hinting --
              # This leaves a small file in the home directory that "records" 
              # which hardware variant was chosen. Used by the impure alias logic.
              home.file.".nix-gpu-hint".text = if gpu != null then gpu else "generic";
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

          # 2.1. Portable Matrix: Generate "Pure" base configs (e.g., "ikci@x86_64-linux")
          baseConfigs = lib.listToAttrs (lib.concatMap (system:
            map (username: {
              name = "${username}@${system}";
              value = mkHome { inherit username system; };
            }) allUsers
          ) supportedSystems);

          # 2.2. Specialized Matrix: Generate flavor configs (e.g., "ikci@x86_64-linux+rocm")
          specializedConfigs = lib.listToAttrs (lib.concatMap (system:
            lib.concatMap (username:
              map (gpu: {
                name = "${username}@${system}+${gpu}";
                value = mkHome { inherit username system; inherit gpu; };
              }) specialGpus
            ) allUsers
          ) supportedSystems);

          # 2.3. Impure Auto-Aliases: Generates bare "username" aliases based on hardware.
          # Requires: --impure flag and a pre-existing .nix-gpu-hint file.
          # Logic: Lazily resolves the home path from the ingredients (baseConfigs).
          impureAliases = if (builtins ? currentSystem) then
            let
              # Filter users to only those who have an existing hint file on the disk.
              # Note: For security/permissions, we only check the user currently running the command.
              targetUsername = builtins.getEnv "USER";

              # A helper to find a user's hint based on their defined home directory.
              getUserAlias = username:
                let
                  # Peek into the base config ingredient to find the home path.
                  baseConfig = baseConfigs."${username}@${builtins.currentSystem}";
                  homeDir = baseConfig.config.home.homeDirectory;
                  hintPath = /. + homeDir + "/.nix-gpu-hint";

                  # Resolve the hint if it exists.
                  hasHint = builtins.pathExists hintPath;
                  gpuHint = if hasHint then lib.trim (builtins.readFile hintPath) else null;
                in
                if gpuHint != null then {
                  name = username;
                  value = if gpuHint == "rocm" || gpuHint == "cuda"
                          then specializedConfigs."${username}@${builtins.currentSystem}+${gpuHint}"
                          else baseConfig;
                } else null;

              # We only generate the alias for the active user to avoid permission errors
              # on other users' home directories during evaluation.
              activeAlias = getUserAlias targetUsername;
            in
            if activeAlias != null then { "${activeAlias.name}" = activeAlias.value; } else {}
          else {};

        in
        # Merge the pure portable matrix with the context-aware impure aliases.
        baseConfigs // specializedConfigs // impureAliases;
    };
}
