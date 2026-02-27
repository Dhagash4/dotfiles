require('nvim-treesitter').setup {
  -- Parsers to install
  install = {
    "c", "cpp", "lua", "vim", "vimdoc", "query",
    "markdown", "markdown_inline",
    "python", "yaml",
    "dockerfile", "gitignore", "cmake",
    "javascript", "typescript", "tsx",
    "html", "css", "scss", "json", "toml"
  },

  -- Install parsers synchronously
  sync_install = false, -- safer to install asynchronously on old systems

  -- Automatically install missing parsers when entering buffer
  auto_install = true,

  -- Prefer prebuilt binaries (skip building from source)
  parser_install_dir = nil, -- default
  prefer_git = false,       -- disables cloning from Git
  prefer_local = false,     -- disables local build

  -- Highlighting configuration
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },

  -- Indentation configuration
  indent = {
    enable = true,
  },
}
