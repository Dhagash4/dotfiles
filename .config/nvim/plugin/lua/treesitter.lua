-- nvim-treesitter is pinned to the `master` branch (see init.vim).
-- master uses the `nvim-treesitter.configs` module API below; the `main`
-- branch rewrite removed it. If you switch branches, this file must change.
local ok, configs = pcall(require, 'nvim-treesitter.configs')
if not ok then
  -- Plugin not on the master branch yet. Run:
  --   :PlugUpdate nvim-treesitter   then   :TSUpdate   and restart nvim.
  return
end

configs.setup {
  -- Parsers to install
  ensure_installed = {
    "c", "cpp", "lua", "vim", "vimdoc", "query",
    "markdown", "markdown_inline",
    "python", "yaml",
    "dockerfile", "gitignore", "cmake",
    "javascript", "typescript", "tsx",
    "html", "css", "scss", "json", "toml",
  },

  -- Install parsers asynchronously, and auto-install missing ones on buffer enter
  sync_install = false,
  auto_install = true,

  -- Highlighting (this is what was silently disabled before)
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },

  -- Indentation
  indent = {
    enable = true,
  },
}
