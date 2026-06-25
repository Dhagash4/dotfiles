# Dotfiles

My personal dotfiles, managed with [yadm](https://yadm.io). One command sets up a fresh
machine — Linux (work) or macOS (personal) — with the same editor and font experience.

## Install

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/Dhagash4/dotfiles/master/.config/yadm/install.sh)"
```

This installs prerequisites (Homebrew on macOS, yadm via apt on Linux), clones this repo,
and runs `.config/yadm/bootstrap`, which:

- installs CLI packages (`.config/yadm/packages` + OS-specific lists)
- installs WezTerm and VS Code
- installs oh-my-zsh and the zsh plugins
- installs Neovim (latest stable), node (via nvm), vim-plug plugins, and coc extensions
- installs VS Code extensions (`.config/yadm/vscode-extensions.txt`)
- installs the SFMono Nerd Font (used by WezTerm and VS Code)

Work/machine-specific files (`.zsh_work`, `.aliases_work.zsh`, …) are not tracked and are
sourced only if present.

## Layout

- `.config/yadm/install.sh` — bootstrap entry point (the curl one-liner above)
- `.config/yadm/bootstrap` — orchestrator run after clone
- `.config/yadm/functions.sh` — the install steps
- `.config/yadm/{packages,linux_packages,macos_packages,macos_casks}` — package manifests
- `.config/fonts/install_fonts.sh##os.{Linux,Darwin}` — font installers (yadm OS-alternates)

## Acknowledgements

Heavily inspired by [Ignacio Vizzo](https://github.com/nachovizzo),
[Benedikt Mersch](https://github.com/benemer) and
[Sumanth Nagulavancha](https://github.com/sumanthrao1997).
