return {
  cmd = { "haskell-language-server-wrapper", "--lsp" },
  filetypes = { "haskell", "lhaskell" },
  root_markers = {
    "hie.yaml",
    "cabal.project",
    "*.cabal",
    "package.yaml",
    "stack.yaml",
    ".git"
  },
}
