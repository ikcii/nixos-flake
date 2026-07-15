{ config, pkgs, lib, ... }:

{
  programs = {
    emacs = {
      enable = true;
      extraPackages = epkgs: [
        epkgs.evil
        epkgs.corfu
        epkgs.vertico
      ];
    };

    mnw =
      let
        onlyColorStrings = lib.filterAttrs (
          name: value: builtins.isString value && lib.hasPrefix "base" name
        ) config.lib.stylix.colors;

        stylixLuaColors = lib.concatStringsSep "\n" (
          lib.mapAttrsToList (name: value: "  [\"${name}\"] = \"#${value}\",") onlyColorStrings
        );

        stylix-nvim-theme = pkgs.writeText "stylix-theme.lua" ''
          local colors = {
            ${stylixLuaColors}
          }

          require('base16-colorscheme').setup(colors)

          if ${toString config.stylix.opacity.applications} < 1 then
            vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
            vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
          end
        '';
      in
      {
        enable = true;
        neovim = pkgs.neovim-unwrapped;

        luaFiles = [
          ../../../users/ikci/home/nvim/init.lua
          stylix-nvim-theme
        ];

        plugins = {
          start = with pkgs.vimPlugins; [
            lazy-nvim
          ];

          opt =
            let
              pluginDir = ../../../users/ikci/home/nvim/lua/plugins;
              pluginFiles = builtins.attrNames (builtins.readDir pluginDir);
              pluginNames = map (lib.removeSuffix ".lua") (lib.filter (x: lib.hasSuffix ".lua" x) pluginFiles);
              autoPlugins = map (name: pkgs.vimPlugins.${name}) pluginNames;
            in
            autoPlugins ++ [ pkgs.vimPlugins.nvim-treesitter.withAllGrammars ];

          dev.config = {
            pure = ../../../users/ikci/home/nvim;
          };
        };
      };
  };

  home.packages = with pkgs; [
    # LSPs
    bash-language-server
    csharp-ls
    haskell-language-server
    lua-language-server
    nil
    pyright

    # Additional Dev Tools
    dotnetCorePackages.sdk_10_0
  ];
}
