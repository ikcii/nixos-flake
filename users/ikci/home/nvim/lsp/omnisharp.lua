return {
  cmd = {
    "omnisharp-mono",
    "--languageserver",
    "--hostPID",
    tostring(vim.fn.getpid()),
  },
  filetypes = { "cs" },
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local root = vim.fs.root(fname, function(name)
      return name:match("%.sln$") ~= nil
          or name:match("%.csproj$") ~= nil
          or name == ".git"
    end)
    if root then
      on_dir(root)
    end
  end,
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
      enabled = true,
      loadProjectsOnDemand = true,
    },
  },
}
