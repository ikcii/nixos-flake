return {
  cmd = {
    "omnisharp",
    "--languageserver",
    "--hostPID",
    vim.fn.getpid(),
  },
  filetypes = { "cs" },
  root_markers = { "*.sln", "*.csproj", ".git" },
  init_options = {
    useModernNet = false,
  },
  settings = {
    FormattingOptions = {
      tabSize = 4,
      indentSize = 4,
    },
    RoslynExtensionsOptions = {
      enableDecompilationSupport = true,
      AnalyzeOpenDocumentsOnly = false,
    },
    msbuild = {
      loadProjectsOnDemand = true,
    },
  },
}
