local port = os.getenv('GDScript_Port') or '6005'

return {
  name = "godot",
  cmd = vim.lsp.rpc.connect('127.0.0.1', tonumber(port)),
  filetypes = { "gdscript" },
  root_markers = { "project.godot", ".git" },
}
