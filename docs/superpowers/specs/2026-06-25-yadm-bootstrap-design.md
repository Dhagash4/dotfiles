# yadm One-Click Bootstrap — Design

**Date:** 2026-06-25
**Goal:** Make the yadm dotfiles repo (`git@github.com:Dhagash4/dotfiles.git`) install in one
command on a fresh machine — Linux (work) and macOS (personal) — with an editor and font
experience that is consistent across both. Heavily inspired by
[nachovizzo/dotfiles](https://github.com/nachovizzo/dotfiles). Keep it simple; do not overengineer.

## Decisions

| Topic | Decision |
|---|---|
| Packages | apt on Linux + brew on macOS (split package manifests) |
| Editors | Both Neovim and VS Code — tracked and bootstrapped |
| Terminal | wezterm as the single standard; untrack kitty (leave files on disk) |
| Font | SFMono Nerd Font on both, in terminals and VS Code |
| Secrets | No yadm encryption; work/local files load only if present |

## Architecture — the 3-layer pattern

A fresh machine runs one command:

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/Dhagash4/dotfiles/master/.config/yadm/install.sh)"
```

Flow, all under `.config/yadm/`:

```
install.sh   → detect OS; install prerequisites (brew on macOS / apt on Linux) + yadm;
               clone repo over HTTPS with bootstrap enabled; switch remote to SSH.
bootstrap    → orchestrator; sources functions.sh and calls each install_* step with
               `|| true` so one failing step does not abort the whole run.
functions.sh → the work: install_packages, install_ohmyzsh, install_nvim,
               install_vscode, install_fonts.
```

### Package manifests (alongside the scripts)

```
packages          # names valid for BOTH apt & brew (e.g. tmux, fzf, ripgrep, btop)
linux_packages    # apt-only extras (build-essential, xclip, curl, etc.)
macos_packages    # brew formulae
macos_casks       # brew casks: wezterm, visual-studio-code, font-sf-mono-nerd-font
vscode-extensions.txt   # one extension id per line
```

`install_packages` branches on `uname -s`: Darwin → `brew install` from `packages` +
`macos_packages`, `brew install --cask` from `macos_casks`; Linux → `sudo apt update` then
`xargs apt install -y` from `packages` + `linux_packages`.

## Components

### install_ohmyzsh
Installs oh-my-zsh non-interactively (`RUNZSH=no KEEP_ZSHRC=yes CHSH=no`), sets zsh as the
default shell, then clones the external plugins referenced in `.zshrc`:
`zsh-autosuggestions`, `zsh-syntax-highlighting`, `fzf-tab` into `$ZSH_CUSTOM/plugins`.

### install_nvim
- **Linux:** download the latest stable Neovim release tarball
  (`nvim-linux-x86_64.tar.gz` from `github.com/neovim/neovim/releases/latest`), extract to
  `/usr/local/`, symlink `/usr/local/bin/nvim`. This matches the current install (v0.11.5).
- **macOS:** `brew install neovim`.
- Install **nvm + node LTS** (coc requires node; current setup uses nvm).
- Run `nvim --headless +PlugInstall +qall`, then install the coc extensions
  (read from `coc_global_extensions`).

### install_vscode
- Track `~/.config/Code/User/settings.json`.
- On macOS, symlink `~/Library/Application Support/Code/User` → `~/.config/Code/User`
  so a single settings file serves both OSes.
- Install every extension in `vscode-extensions.txt` via `code --install-extension`.
- **settings.json portability fixes:**
  - Font family `'SF Mono Nerd Font'` → `'SFMono Nerd Font'` (match the real installed
    family / wezterm; current value silently falls back to monospace).
  - Remove hard-coded `clangd.path` and `clang-format.executable` (`/usr/bin/...`, Linux-only)
    and the `query-driver` absolute paths so the clangd extension auto-detects the binary
    on both Linux and macOS.

### install_fonts (yadm alternate files, per the reference repo)
- `.config/fonts/install_fonts.sh##os.Linux` — download the `epk/SF-Mono-Nerd-Font` release
  tarball and copy the `.otf` files into `~/.local/share/fonts/`, then refresh the cache.
- `.config/fonts/install_fonts.sh##os.Darwin` — `brew tap epk/epk && brew install --cask
  font-sf-mono-nerd-font`.
- yadm symlinks the OS-appropriate variant to `install_fonts.sh`.

## Shell robustness (.zshrc)
`.zshrc` currently hard-sources files absent on a fresh machine, breaking the first shell.
Guard them so the shell boots cleanly and optional pieces load only when present:
- `.aliases_work.zsh`, `.zsh_work`, `~/dev/ros2-aliases/ros2_utils.zsh` → `[ -f … ] && source`.
- `eval $(thefuck --alias)` → guard with `command -v thefuck >/dev/null 2>&1 &&`.

No encryption. Work/machine-specific files remain untracked and load opportunistically.

## Cleanup
- Untrack kitty configs: `yadm rm --cached .config/kitty/*` (files stay on disk).
- Update `README.md` with the one-line install command and a short "what it does" note.

## Out of scope (YAGNI)
- yadm encryption / secrets management.
- CI / GitHub Actions docker test of the bootstrap.
- Theming or plugin changes beyond what is needed for portability.

## Validation
- Bootstrap steps are individually idempotent and guarded with `|| true`.
- A fresh-shell smoke test: confirm `.zshrc` sources without error when work/local files
  are absent.
- Confirm `fc-list | grep -i sfmono` after `install_fonts`, and `code --list-extensions`
  matches `vscode-extensions.txt`.
