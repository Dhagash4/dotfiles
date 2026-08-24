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
- installs the Claude Code CLI (`claude`)
- installs VS Code extensions (`.config/yadm/vscode-extensions.txt`)
- installs the SFMono Nerd Font (used by WezTerm and VS Code) and verifies fontconfig can see it
- installs `keyd` (built from source) and points `/etc/keyd/default.conf` at `.config/keyboard/keyd.conf`

Each step runs even if an earlier one fails; any failures are listed at the end and the
bootstrap exits non-zero. Re-run a single step with:

```sh
source ~/.config/yadm/functions.sh && install_fonts   # or install_claude, install_gui, ...
```

Work/machine-specific files (`.zsh_work`, `.aliases_work.zsh`, …) are not tracked and are
sourced only if present.

## Layout

- `.config/yadm/install.sh` — bootstrap entry point (the curl one-liner above)
- `.config/yadm/bootstrap` — orchestrator run after clone
- `.config/yadm/functions.sh` — the install steps
- `.config/yadm/{packages,linux_packages,macos_packages,macos_casks}` — package manifests
- `.config/fonts/install_fonts.sh##os.{Linux,Darwin}` — font installers (yadm OS-alternates)
- `.config/keyboard/keyd.conf` — keyd remaps (capslock -> control/escape); linked to `/etc/keyd/default.conf`

## Troubleshooting

**WezTerm: "Unable to load a font specified by your font=wezterm.font('SFMono Nerd Font'...)"**

The font is not registered with fontconfig. Install it and check:

```sh
source ~/.config/yadm/functions.sh && install_fonts
fc-list -f '%{family}\n' | grep -i 'SFMono Nerd Font'
```

`fc-cache`/`fc-list` come from the `fontconfig` package, not from `libfontconfig1` that
WezTerm itself depends on, so a minimal/server/WSL install can run WezTerm and still be
unable to register fonts. `fontconfig` is in `.config/yadm/linux_packages` for that reason.

**keyd: capslock is not remapped**

`keyd` is not in the Ubuntu 22.04 repos, so the bootstrap builds it from source. Check it:

```sh
systemctl status keyd
readlink -f /etc/keyd/default.conf   # -> ~/.config/keyboard/keyd.conf
```

Re-run the step, or reload after editing the config:

```sh
source ~/.config/yadm/functions.sh && install_keyd
sudo systemctl restart keyd
```

keyd works at the evdev level, so it applies under both X11 and Wayland, and to the
console. It needs root — the step uses `sudo`, so run the bootstrap where you can
authenticate.

## Acknowledgements

Heavily inspired by [Ignacio Vizzo](https://github.com/nachovizzo),
[Benedikt Mersch](https://github.com/benemer) and
[Sumanth Nagulavancha](https://github.com/sumanthrao1997).
