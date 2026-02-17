return {
  cmd = { "nil" },
  filetypes = { "nix" },
  root_markers = { "flake.nix", ".git" },
  settings = {
    ["nil"] = {
      formatting = {
        command = { "nixfmt" }
      },
      nix = {
        binary = "nix",
        maxMemoryMB = nil,
      },
      flake = {
        autoArchive = true,
        autoEvalInputs = true,
        nixpkgsInputName = "nixpkgs",
      },
    },
  },
}
