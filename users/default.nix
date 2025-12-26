{ lib, config, inputs, commonUserModules, ... }:

{
  options.users.list = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = "A list of all user accounts to be created on this system.";
  };

  config = {
    # ================================================================ #
    #                       NIXOS USER CONFIG                          #
    # ================================================================ #
    # Generates standard NixOS user declarations (groups, shell, etc.)
    # based on the users specified in 'config.users.list'.
    users.users = lib.genAttrs config.users.list (username:
      {
        # --- Default Settings ---
        # These are applied to all users unless overridden in their specific file.
        isNormalUser = true;
        description = username;
      }
      # --- User Overrides ---
      # Check if ./<user>/default.nix exists; if so, import and merge it.
      // (if builtins.pathExists ./${username}/default.nix
        then import ./${username}/default.nix { inherit lib config inputs; }
        else {})
    );

    # ================================================================ #
    #                    HOME MANAGER CONFIG                           #
    # ================================================================ #
    # Automatically enables Home Manager for every user in the list.
    home-manager.users = lib.genAttrs config.users.list (username:
      {
        # Bridge nixpkgs config for things such as rocmSupport auto detection in hm
        nixpkgs.config = config.nixpkgs.config;

        imports = [
          # 1. The specific user's home configuration
          (./${username}/home.nix)
        ]
        # 2. The shared modules passed down from flake.nix
        ++ commonUserModules;
      }
    );
  };
}
