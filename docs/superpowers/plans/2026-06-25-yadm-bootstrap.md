# yadm One-Click Bootstrap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the yadm dotfiles repo install in one command on a fresh Linux (work) or macOS (personal) machine, with a consistent editor + font experience.

**Architecture:** Three-layer pattern under `.config/yadm/` — `install.sh` (curl entry point: prerequisites + yadm + clone) → `bootstrap` (orchestrator) → `functions.sh` (the install steps). OS branching via `uname -s`. Font handled via yadm OS-alternate scripts.

**Tech Stack:** POSIX sh / bash, yadm, Homebrew (macOS), apt (Linux), oh-my-zsh, vim-plug/coc, nvm.

## Global Constraints

- Repo: `git@github.com:Dhagash4/dotfiles.git`, default branch **`master`**.
- Every bootstrap step must be **idempotent** (safe to re-run) and individually guarded so one failure never aborts the rest.
- Package installs go **one package at a time** (`|| true`) so a single missing name does not abort the batch.
- **No encryption.** Work/local files (`.aliases_work.zsh`, `.zsh_work`, ros2 utils) load only when present.
- Font family string is exactly **`SFMono Nerd Font`** (matches the epk patch + wezterm).
- All scripts use `command -v` / `[ -f … ]` guards; no hard-coded absolute tool paths in tracked configs.
- **Each task = one commit, pushed immediately** (`yadm add … && yadm commit && yadm push`). Never one big commit.
- yadm is the git wrapper: use `yadm add/commit/push/rm`, not `git`.
- Scripts cannot be fully executed here (they install software); verification = syntax checks (`bash -n`, `zsh -n`, json validation) + review.

---

### Task 1: Scaffold the 3-layer entry point

**Files:**
- Create: `~/.config/yadm/install.sh`
- Create: `~/.config/yadm/bootstrap`
- Create: `~/.config/yadm/functions.sh` (skeleton with stubs)

**Interfaces:**
- Produces: `install_packages`, `install_gui`, `install_ohmyzsh`, `install_nvim`, `install_vscode` (defined as stubs here, filled in later tasks); helpers `_is_mac`, `_brew_install_each`, `_brew_cask_each`, `_apt_install_each`; global `YADM_DIR="$HOME/.config/yadm"`.

- [ ] **Step 1: Create `install.sh`**

```sh
#!/bin/sh
# One-click dotfiles installer.
# Usage:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/Dhagash4/dotfiles/master/.config/yadm/install.sh)"
set -e

REPO_HTTPS="https://github.com/Dhagash4/dotfiles.git"
REPO_SSH="git@github.com:Dhagash4/dotfiles.git"

install_brew() {
  if ! command -v brew >/dev/null 2>&1; then
    NONINTERACTIVE=1 /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  if [ -d /opt/homebrew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

case "$(uname -s)" in
  Darwin)
    install_brew
    brew install yadm
    ;;
  *)
    sudo apt update
    sudo apt install -y yadm git curl
    ;;
esac

# Clone and run bootstrap; if already cloned, just run bootstrap.
yadm clone --bootstrap "$REPO_HTTPS" || yadm bootstrap

# Switch to SSH for future operations.
yadm remote set-url origin "$REPO_SSH" || true
```

- [ ] **Step 2: Create `bootstrap`**

```bash
#!/bin/bash
# Orchestrates a fresh-machine setup. Run automatically by `yadm clone --bootstrap`.
set -e

YADM_DIR="$(dirname "$(realpath "$0")")"
# shellcheck source=/dev/null
source "$YADM_DIR/functions.sh"

install_packages || true
install_gui      || true
install_ohmyzsh  || true
install_nvim     || true
install_vscode   || true

# Fonts: yadm symlinks the OS-appropriate variant to install_fonts.sh.
if [ -x "$HOME/.config/fonts/install_fonts.sh" ]; then
  "$HOME/.config/fonts/install_fonts.sh" || true
fi

echo "Bootstrap complete. Run 'exec zsh' (or open a new terminal) to load everything."
```

- [ ] **Step 3: Create `functions.sh` (skeleton)**

```bash
#!/bin/bash
# Shared bootstrap functions. Sourced by ~/.config/yadm/bootstrap.

YADM_DIR="$HOME/.config/yadm"

_is_mac() { [ "$(uname -s)" = "Darwin" ]; }

# Install a newline-delimited package list one entry at a time, so a single
# missing package never aborts the whole batch.
_brew_install_each() { while read -r p; do [ -n "$p" ] && brew install "$p" || true; done < "$1"; }
_brew_cask_each()    { while read -r p; do [ -n "$p" ] && brew install --cask "$p" || true; done < "$1"; }
_apt_install_each()  { while read -r p; do [ -n "$p" ] && sudo apt install -y "$p" || true; done < "$1"; }

install_packages() { echo "TODO task 2"; }
install_gui()      { echo "TODO task 3"; }
install_ohmyzsh()  { echo "TODO task 4"; }
install_nvim()     { echo "TODO task 5"; }
install_vscode()   { echo "TODO task 6"; }
```

- [ ] **Step 4: Make scripts executable**

Run: `chmod +x ~/.config/yadm/install.sh ~/.config/yadm/bootstrap ~/.config/yadm/functions.sh`

- [ ] **Step 5: Syntax-check all three**

Run: `sh -n ~/.config/yadm/install.sh && bash -n ~/.config/yadm/bootstrap && bash -n ~/.config/yadm/functions.sh && echo OK`
Expected: `OK`

- [ ] **Step 6: Commit and push**

```bash
cd ~ && yadm add .config/yadm/install.sh .config/yadm/bootstrap .config/yadm/functions.sh
yadm commit -m "feat(yadm): scaffold install.sh, bootstrap, functions skeleton"
yadm push origin HEAD
```

---

### Task 2: Package manifests + `install_packages`

**Files:**
- Create: `~/.config/yadm/packages`, `linux_packages`, `macos_packages`, `macos_casks`
- Modify: `~/.config/yadm/functions.sh` (replace `install_packages` stub)

**Interfaces:**
- Consumes: `_is_mac`, `_brew_install_each`, `_apt_install_each`, `YADM_DIR`.

- [ ] **Step 1: Create `packages` (names valid in BOTH apt and brew)**

```
btop
fzf
git
jq
ripgrep
tmux
universal-ctags
wget
zoxide
```

- [ ] **Step 2: Create `linux_packages` (apt-only)**

```
build-essential
curl
fd-find
thefuck
unzip
xclip
```

- [ ] **Step 3: Create `macos_packages` (brew formulae)**

```
fd
neovim
thefuck
```

- [ ] **Step 4: Create `macos_casks` (brew casks)**

```
wezterm
visual-studio-code
```

- [ ] **Step 5: Replace `install_packages` in `functions.sh`**

```bash
install_packages() {
  if _is_mac; then
    _brew_install_each "$YADM_DIR/packages"
    _brew_install_each "$YADM_DIR/macos_packages"
  else
    sudo apt update
    _apt_install_each "$YADM_DIR/packages"
    _apt_install_each "$YADM_DIR/linux_packages"
  fi
}
```

- [ ] **Step 6: Syntax-check**

Run: `bash -n ~/.config/yadm/functions.sh && echo OK`
Expected: `OK`

- [ ] **Step 7: Commit and push**

```bash
cd ~ && yadm add .config/yadm/packages .config/yadm/linux_packages .config/yadm/macos_packages .config/yadm/macos_casks .config/yadm/functions.sh
yadm commit -m "feat(yadm): add package manifests and install_packages"
yadm push origin HEAD
```

---

### Task 3: `install_gui` (wezterm + VS Code binaries)

**Files:**
- Modify: `~/.config/yadm/functions.sh` (replace `install_gui` stub)

**Interfaces:**
- Consumes: `_is_mac`, `_brew_cask_each`, `YADM_DIR`.
- Produces: a `code` and `wezterm` binary on PATH after run.

- [ ] **Step 1: Replace `install_gui` in `functions.sh`**

```bash
install_gui() {
  if _is_mac; then
    _brew_cask_each "$YADM_DIR/macos_casks"
    return 0
  fi

  # Linux: add official apt repos, then install. Idempotent via command -v guards.
  if ! command -v code >/dev/null 2>&1; then
    sudo apt install -y wget gpg apt-transport-https
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
      | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft.gpg >/dev/null
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
      | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
    sudo apt update && sudo apt install -y code
  fi

  if ! command -v wezterm >/dev/null 2>&1; then
    curl -fsSL https://apt.fury.io/wez/gpg.key \
      | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
    echo "deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *" \
      | sudo tee /etc/apt/sources.list.d/wezterm.list >/dev/null
    sudo apt update && sudo apt install -y wezterm
  fi
}
```

- [ ] **Step 2: Syntax-check**

Run: `bash -n ~/.config/yadm/functions.sh && echo OK`
Expected: `OK`

- [ ] **Step 3: Commit and push**

```bash
cd ~ && yadm add .config/yadm/functions.sh
yadm commit -m "feat(yadm): install wezterm and VS Code (casks on mac, apt repos on linux)"
yadm push origin HEAD
```

---

### Task 4: `install_ohmyzsh`

**Files:**
- Modify: `~/.config/yadm/functions.sh` (replace `install_ohmyzsh` stub)

**Interfaces:**
- Produces: `~/.oh-my-zsh` + the three external plugins (`zsh-autosuggestions`, `zsh-syntax-highlighting`, `fzf-tab`) referenced by `.zshrc`; zsh as default shell.

- [ ] **Step 1: Replace `install_ohmyzsh` in `functions.sh`**

```bash
install_ohmyzsh() {
  export RUNZSH=no KEEP_ZSHRC=yes CHSH=no
  export ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi

  git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions" 2>/dev/null || true
  git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting \
    "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" 2>/dev/null || true
  git clone --depth 1 https://github.com/Aloxaf/fzf-tab \
    "$ZSH_CUSTOM/plugins/fzf-tab" 2>/dev/null || true

  # Make zsh the default shell.
  if [ "$(basename "${SHELL:-}")" != "zsh" ] && command -v zsh >/dev/null 2>&1; then
    sudo chsh -s "$(command -v zsh)" "$USER" 2>/dev/null || chsh -s "$(command -v zsh)" || true
  fi
}
```

- [ ] **Step 2: Syntax-check**

Run: `bash -n ~/.config/yadm/functions.sh && echo OK`
Expected: `OK`

- [ ] **Step 3: Commit and push**

```bash
cd ~ && yadm add .config/yadm/functions.sh
yadm commit -m "feat(yadm): install oh-my-zsh and zsh plugins, set default shell"
yadm push origin HEAD
```

---

### Task 5: `install_nvim` (neovim + nvm/node + plugins + coc)

**Files:**
- Modify: `~/.config/yadm/functions.sh` (replace `install_nvim` stub)

**Interfaces:**
- Consumes: `_is_mac`.
- Produces: `nvim` on PATH (latest stable on Linux, brew on mac), node via nvm, installed vim-plug plugins and coc extensions.

- [ ] **Step 1: Replace `install_nvim` in `functions.sh`**

```bash
install_nvim() {
  if _is_mac; then
    brew install neovim || true
  elif ! command -v nvim >/dev/null 2>&1; then
    # Latest stable prebuilt release tarball -> /usr/local (matches current install).
    tmp="$(mktemp -d)"
    curl -fsSL -o "$tmp/nvim.tar.gz" \
      https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    sudo tar -C /usr/local -xzf "$tmp/nvim.tar.gz"
    sudo ln -sf /usr/local/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
    rm -rf "$tmp"
  fi

  # node via nvm (coc.nvim needs node); matches current nvm-based setup.
  export NVM_DIR="$HOME/.nvm"
  if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  fi
  # shellcheck source=/dev/null
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  command -v nvm >/dev/null 2>&1 && nvm install --lts >/dev/null 2>&1 || true

  # vim-plug plugins, then coc extensions declared in g:coc_global_extensions.
  nvim --headless +PlugInstall +qall 2>/dev/null || true
  exts="$(nvim --headless -c 'echo join(get(g:,"coc_global_extensions",[]), " ")' +qa 2>&1 | tr -d '\r')"
  if [ -n "$exts" ]; then
    nvim --headless -c "CocInstall -sync $exts" +qall 2>/dev/null || true
  fi
}
```

- [ ] **Step 2: Syntax-check**

Run: `bash -n ~/.config/yadm/functions.sh && echo OK`
Expected: `OK`

- [ ] **Step 3: Confirm coc extensions are discoverable**

Run: `nvim --headless -c 'echo join(get(g:,"coc_global_extensions",[]), " ")' +qa 2>&1 | tr -d '\r'`
Expected: a space-separated list of coc extensions (or empty if none declared — either is acceptable; the script guards on emptiness).

- [ ] **Step 4: Commit and push**

```bash
cd ~ && yadm add .config/yadm/functions.sh
yadm commit -m "feat(yadm): install neovim, nvm/node, vim-plug plugins and coc extensions"
yadm push origin HEAD
```

---

### Task 6: Track VS Code config + extensions, fix portability, `install_vscode`

**Files:**
- Modify: `~/.config/Code/User/settings.json` (font + remove absolute tool paths), then track it
- Create: `~/.config/yadm/vscode-extensions.txt`
- Modify: `~/.config/yadm/functions.sh` (replace `install_vscode` stub)

**Interfaces:**
- Consumes: `_is_mac`, `YADM_DIR`, a `code` binary on PATH.

- [ ] **Step 1: Fix font family in `settings.json`**

Change the line:
```json
    "editor.fontFamily": "'SF Mono Nerd Font', 'monospace', monospace",
```
to:
```json
    "editor.fontFamily": "'SFMono Nerd Font', monospace",
```

- [ ] **Step 2: Remove the Linux-only `clangd.path` line**

Delete this line entirely (the clangd extension auto-detects the binary):
```json
    "clangd.path": "/usr/bin/clangd",
```

- [ ] **Step 3: Remove the absolute `--query-driver` argument**

Inside `"clangd.arguments"`, delete this one array element (keep the rest):
```json
        "--query-driver=/usr/bin/c++,/usr/bin/g++,/usr/bin/gcc",
```
Ensure the preceding array element (`"--pch-storage=memory"`) keeps its trailing comma only if another element follows it; the final element must have no trailing comma.

- [ ] **Step 4: Remove the Linux-only `clang-format.executable` line**

Delete this line entirely (the `xaver.clang-format` extension falls back to its bundled binary or brew's):
```json
    "clang-format.executable": "/usr/bin/clang-format",
```

- [ ] **Step 5: Validate the JSON is still well-formed**

Run: `python3 -c "import json,sys; json.load(open('$HOME/.config/Code/User/settings.json'))" && echo VALID`
Expected: `VALID`
(Note: VS Code tolerates `//` comments but `json.load` does not. If the file has comments, validate with: `code --list-extensions >/dev/null && echo "rely on editor"` and instead eyeball-verify the edits — do NOT strip the comments.)

- [ ] **Step 6: Generate `vscode-extensions.txt` from the current machine**

Run: `code --list-extensions > ~/.config/yadm/vscode-extensions.txt && cat ~/.config/yadm/vscode-extensions.txt`
Expected: ~20 ids including `jdinhlife.gruvbox`, `vscodevim.vim`, `llvm-vs-code-extensions.vscode-clangd`, `xaver.clang-format`, `ms-vscode.cmake-tools`.

- [ ] **Step 7: Replace `install_vscode` in `functions.sh`**

```bash
install_vscode() {
  command -v code >/dev/null 2>&1 || return 0

  # macOS stores user config under Library; point it at the tracked path.
  if _is_mac; then
    mac_dir="$HOME/Library/Application Support/Code/User"
    if [ ! -L "$mac_dir" ]; then
      rm -rf "$mac_dir"
      mkdir -p "$HOME/Library/Application Support/Code"
      ln -s "$HOME/.config/Code/User" "$mac_dir"
    fi
  fi

  while read -r ext; do
    [ -n "$ext" ] && code --install-extension "$ext" --force || true
  done < "$YADM_DIR/vscode-extensions.txt"
}
```

- [ ] **Step 8: Syntax-check**

Run: `bash -n ~/.config/yadm/functions.sh && echo OK`
Expected: `OK`

- [ ] **Step 9: Commit and push**

```bash
cd ~ && yadm add .config/Code/User/settings.json .config/yadm/vscode-extensions.txt .config/yadm/functions.sh
yadm commit -m "feat(yadm): track VS Code settings/extensions, portable font + tool paths"
yadm push origin HEAD
```

---

### Task 7: Font install (yadm OS-alternate scripts) + bootstrap hook

**Files:**
- Create: `~/.config/fonts/install_fonts.sh##os.Linux`
- Create: `~/.config/fonts/install_fonts.sh##os.Darwin`

(The bootstrap hook calling `~/.config/fonts/install_fonts.sh` already exists from Task 1. yadm symlinks the OS-appropriate variant to `install_fonts.sh` on `yadm alt`/clone.)

- [ ] **Step 1: Create `install_fonts.sh##os.Linux`**

```bash
#!/bin/bash
# Install SFMono Nerd Font on Linux (epk patch — same family used by wezterm + VS Code).
set -e
if fc-list 2>/dev/null | grep -qi "SFMono"; then
  echo "SFMono Nerd Font already installed."
  exit 0
fi
ver="18.0d1e1.0"
tmp="$(mktemp -d)"
curl -fsSL -o "$tmp/sfmono.tar.gz" \
  "https://github.com/epk/SF-Mono-Nerd-Font/archive/refs/tags/v${ver}.tar.gz"
tar -xzf "$tmp/sfmono.tar.gz" -C "$tmp"
mkdir -p "$HOME/.local/share/fonts"
cp "$tmp/SF-Mono-Nerd-Font-${ver}/"*.otf "$HOME/.local/share/fonts/" 2>/dev/null || \
  cp -r "$tmp/SF-Mono-Nerd-Font-${ver}/"* "$HOME/.local/share/fonts/"
fc-cache -f "$HOME/.local/share/fonts" >/dev/null
rm -rf "$tmp"
echo "SFMono Nerd Font installed."
```

- [ ] **Step 2: Create `install_fonts.sh##os.Darwin`**

```bash
#!/bin/bash
# Install SFMono Nerd Font on macOS via the epk Homebrew tap.
set -e
if brew list --cask font-sf-mono-nerd-font >/dev/null 2>&1; then
  echo "SFMono Nerd Font already installed."
  exit 0
fi
brew tap epk/epk
brew install --cask font-sf-mono-nerd-font
```

- [ ] **Step 3: Make both executable**

Run: `chmod +x ~/.config/fonts/install_fonts.sh##os.Linux ~/.config/fonts/install_fonts.sh##os.Darwin`

- [ ] **Step 4: Syntax-check both**

Run: `bash -n '/home/dhagash/.config/fonts/install_fonts.sh##os.Linux' && bash -n '/home/dhagash/.config/fonts/install_fonts.sh##os.Darwin' && echo OK`
Expected: `OK`

- [ ] **Step 5: Materialize the alternate symlink locally**

Run: `yadm add '.config/fonts/install_fonts.sh##os.Linux' '.config/fonts/install_fonts.sh##os.Darwin' && yadm alt && ls -l ~/.config/fonts/install_fonts.sh`
Expected: `install_fonts.sh` symlink resolves to the `##os.Linux` variant on this machine.

- [ ] **Step 6: Commit and push**

```bash
cd ~ && yadm commit -m "feat(yadm): add SFMono Nerd Font installers (linux download / mac cask)"
yadm push origin HEAD
```

---

### Task 8: Make `.zshrc` fresh-machine safe

**Files:**
- Modify: `~/.zshrc`

**Interfaces:** none (shell config).

- [ ] **Step 1: Guard the `thefuck` eval**

Change:
```zsh
eval $(thefuck --alias)
```
to:
```zsh
command -v thefuck >/dev/null 2>&1 && eval "$(thefuck --alias)"
```

- [ ] **Step 2: Guard the optional source lines**

Change this block:
```zsh
source $HOME/.aliases.zsh
source $HOME/.aliases_work.zsh
source $HOME/.functions.zsh
source $HOME/.zsh_work
source $HOME/.ros.sh
source ~/dev/ros2-aliases/ros2_utils.zsh
```
to:
```zsh
source $HOME/.aliases.zsh
[ -f $HOME/.aliases_work.zsh ] && source $HOME/.aliases_work.zsh
source $HOME/.functions.zsh
[ -f $HOME/.zsh_work ] && source $HOME/.zsh_work
source $HOME/.ros.sh
[ -f $HOME/dev/ros2-aliases/ros2_utils.zsh ] && source $HOME/dev/ros2-aliases/ros2_utils.zsh
```
(`.aliases.zsh`, `.functions.zsh`, `.ros.sh` are tracked and always present after clone, so they stay unguarded.)

- [ ] **Step 3: Syntax-check the zshrc**

Run: `zsh -n ~/.zshrc && echo OK`
Expected: `OK`

- [ ] **Step 4: Verify it sources cleanly when work files are absent**

Run: `zsh -ic 'echo ZSHRC_OK' 2>&1 | tail -3`
Expected: ends with `ZSHRC_OK` and no "no such file or directory" errors for `.aliases_work.zsh` / `.zsh_work` / `ros2_utils.zsh`.

- [ ] **Step 5: Commit and push**

```bash
cd ~ && yadm add .zshrc
yadm commit -m "fix(zsh): guard optional sources and thefuck so a fresh shell boots cleanly"
yadm push origin HEAD
```

---

### Task 9: Untrack kitty + update README

**Files:**
- Untrack: `.config/kitty/*` (files remain on disk)
- Modify: `~/README.md`

- [ ] **Step 1: Untrack kitty configs (leave files on disk)**

Run:
```bash
cd ~ && yadm rm --cached .config/kitty/kitty.conf .config/kitty/current-theme.conf .config/kitty/gruvbox_dark.conf
```
Expected: each shown as `rm '.config/kitty/...'`; `ls ~/.config/kitty/` still lists the files.

- [ ] **Step 2: Rewrite `README.md`**

```markdown
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
```

- [ ] **Step 3: Commit and push**

```bash
cd ~ && yadm add README.md
yadm commit -m "docs: untrack kitty, document one-click install in README"
yadm push origin HEAD
```

---

## Self-Review

**Spec coverage:**
- 3-layer install pattern → Task 1 ✓
- apt/brew split manifests → Task 2 ✓
- wezterm + vscode binaries → Task 3 ✓
- oh-my-zsh + plugins → Task 4 ✓
- nvim (linux tarball/mac brew) + nvm/node + plugins + coc → Task 5 ✓
- VS Code tracked + font fix + remove clangd/clang-format absolute paths + extensions + mac symlink → Task 6 ✓
- SFMono Nerd Font via OS-alternate scripts → Task 7 ✓
- `.zshrc` robustness guards → Task 8 ✓
- untrack kitty, README → Task 9 ✓
- No encryption → honored (no task adds it) ✓

**Placeholder scan:** Task 1 intentionally ships `install_*` stubs that print `TODO task N`; each is replaced in its own later task. No placeholders remain after Task 9.

**Type/name consistency:** Function names (`install_packages/gui/ohmyzsh/nvim/vscode`), helpers (`_is_mac`, `_brew_install_each`, `_brew_cask_each`, `_apt_install_each`), and `YADM_DIR` are used identically across Tasks 1–6. Manifest filenames match between Task 2 (created) and the functions that read them.

**Known limitations (intentional):**
- `keyd` is not auto-installed (not in default apt); `.config/keyboard/keyd.conf` stays tracked but keyd must be installed manually. Documented nowhere yet — acceptable per "keep simple"; revisit only if needed.
- Scripts are syntax-checked, not end-to-end executed, since they install system software.
