return {

  "nvim-treesitter/nvim-treesitter",

  lazy = false,

  -- TODO: Potentially add logic for standalone mode

  opts = {
    auto_install = false,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    indent = { enable = true },
  },

}
