#!/bin/bash
# Shared bootstrap functions. Sourced by ~/.config/yadm/bootstrap.

YADM_DIR="$HOME/.config/yadm"

_is_mac() { [ "$(uname -s)" = "Darwin" ]; }

# Install a newline-delimited package list one entry at a time, so a single
# missing package never aborts the whole batch.
_brew_install_each() { while read -r p; do [ -n "$p" ] && brew install "$p" || true; done < "$1"; }
_brew_cask_each()    { while read -r p; do [ -n "$p" ] && brew install --cask "$p" || true; done < "$1"; }
_apt_install_each()  { while read -r p; do [ -n "$p" ] && sudo apt install -y "$p" || true; done < "$1"; }

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
    sudo chsh -s "$(command -v zsh)" "${USER:-$(id -un)}" 2>/dev/null || chsh -s "$(command -v zsh)" || true
  fi
}
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
# `claude` may not be on PATH yet in this non-interactive shell, so also look where
# the native installer puts it.
_claude_present() { command -v claude >/dev/null 2>&1 || [ -x "$HOME/.local/bin/claude" ]; }

install_claude() {
  if _claude_present; then
    echo "claude already installed."
    return 0
  fi

  # Official native installer; installs to ~/.local/bin, which .zshrc puts on PATH.
  # Check the result rather than the pipeline's status: `curl | bash` reports bash's
  # exit code, so a failed download would otherwise look like a success.
  curl -fsSL https://claude.ai/install.sh | bash || true
  if _claude_present; then
    echo "claude installed (native)."
    return 0
  fi

  # Fallback for platforms with no native build. Uses the node from install_nvim, so
  # keep this step after it in the bootstrap order.
  if command -v npm >/dev/null 2>&1; then
    npm install -g @anthropic-ai/claude-code || true
    if _claude_present; then
      echo "claude installed (npm)."
      return 0
    fi
  fi

  echo "could not install claude (tried the native installer and npm)." >&2
  return 1
}
# keyd is not packaged for Ubuntu 22.04, so build it from source. It hooks in at the
# evdev level, which is why the capslock->control/esc remap works under Wayland too.
install_keyd() {
  if _is_mac; then
    return 0
  fi

  if ! command -v keyd >/dev/null 2>&1; then
    sudo apt-get install -y build-essential git \
      || { sudo apt-get update && sudo apt-get install -y build-essential git; } \
      || { echo "could not install keyd build dependencies." >&2; return 1; }

    tmp="$(mktemp -d)"
    if ! git clone --depth 1 https://github.com/rvaiya/keyd.git "$tmp/keyd"; then
      rm -rf "$tmp"; echo "could not clone keyd." >&2; return 1
    fi
    if ! make -C "$tmp/keyd" || ! sudo make -C "$tmp/keyd" install; then
      rm -rf "$tmp"; echo "keyd build failed." >&2; return 1
    fi
    rm -rf "$tmp"
  fi

  # keyd reads every /etc/keyd/*.conf; point the default at the tracked config so
  # edits to the dotfile take effect after a restart.
  sudo mkdir -p /etc/keyd
  sudo ln -sfn "$HOME/.config/keyboard/keyd.conf" /etc/keyd/default.conf

  # `make install` drops a fresh unit into /usr/local/lib/systemd/system; without a
  # reload systemctl can still report it as not found.
  sudo systemctl daemon-reload
  sudo systemctl enable keyd || { echo "could not enable keyd.service." >&2; return 1; }
  sudo systemctl restart keyd || { echo "could not start keyd.service." >&2; return 1; }

  command -v keyd >/dev/null 2>&1 || { echo "keyd installed but not on PATH." >&2; return 1; }
  echo "keyd installed and running."
}
install_fonts() {
  # yadm symlinks the OS-appropriate variant to install_fonts.sh. Invoke it through
  # bash rather than guarding on [ -x ]: a missing exec bit used to make the whole
  # font step vanish without a word.
  script="$HOME/.config/fonts/install_fonts.sh"
  if [ ! -e "$script" ]; then
    echo "missing $script (did 'yadm alt' run?)" >&2
    return 1
  fi
  bash "$script"
}
# PlotJuggler 4 ships only as a GitHub release (no apt repo, and the Ubuntu archive has
# nothing). The .deb needs sudo and drops an unlinked build in /opt, so take the AppImage
# instead: keep the versioned file under ~/.local/share/plotjuggler and put `pj4` on PATH
# as a symlink, so an upgrade is just a re-point.
install_plotjuggler() {
  if _is_mac; then
    echo "no PlotJuggler build published for macOS; skipping."
    return 0
  fi

  url="$(curl -fsSL https://api.github.com/repos/facontidavide/PlotJuggler/releases/latest \
    | grep -o 'https://[^"]*PlotJuggler-[^"]*-x86_64\.AppImage' | head -1)"
  if [ -z "$url" ]; then
    echo "could not find a PlotJuggler AppImage in the latest release." >&2
    return 1
  fi

  dir="$HOME/.local/share/plotjuggler"
  app="$dir/${url##*/}"
  mkdir -p "$dir" "$HOME/.local/bin"

  if [ -x "$app" ]; then
    echo "plotjuggler4 $(basename "$app") already downloaded."
  else
    if ! curl -fsSL -o "$app" "$url"; then
      rm -f "$app"; echo "could not download $url" >&2; return 1
    fi
    chmod +x "$app"
  fi

  ln -sfn "$app" "$HOME/.local/bin/pj4"
  echo "plotjuggler4 installed (run it with pj4)."
}
# Desktop settings (dock position, top bar, extensions, keyboard) live as dconf dumps
# under ~/.config/gnome. Re-capture them with ~/.config/gnome/dump.sh after tweaking the
# desktop, then commit — that is what keeps a fresh machine from needing a manual pass.
install_gnome_desktop() {
  if _is_mac; then
    return 0
  fi

  script="$HOME/.config/gnome/apply.sh"
  if [ ! -e "$script" ]; then
    echo "missing $script" >&2
    return 1
  fi
  bash "$script"
}
# Claude Code plugins. The install state lives in ~/.claude/plugins, which is machine
# -local (absolute paths, resolved versions), so track two plain lists instead and replay
# them. Regenerate after adding plugins:
#   claude plugin list | grep -oE '[a-z0-9-]+@[a-z-]+' | sort -u   > claude-plugins
# and add any new marketplace to claude-marketplaces.
install_claude_plugins() {
  _claude_present || { echo "claude not installed; skipping plugins." >&2; return 1; }
  cmd="$(command -v claude || echo "$HOME/.local/bin/claude")"

  plugins="$YADM_DIR/claude-plugins"
  markets="$YADM_DIR/claude-marketplaces"
  for f in "$plugins" "$markets"; do
    [ -e "$f" ] || { echo "missing $f" >&2; return 1; }
  done

  # Marketplaces first: a plugin only resolves once its marketplace is configured.
  while read -r name source; do
    case "${name%%#*}" in "") continue ;; esac
    [ -n "$source" ] || continue
    "$cmd" plugin marketplace list 2>/dev/null | grep -q "$name" && continue
    "$cmd" plugin marketplace add "$source" || echo "  !! could not add marketplace $name" >&2
  done < "$markets"

  failed=""
  while read -r entry; do
    entry="${entry%%#*}"; entry="$(echo "$entry" | tr -d '[:space:]')"
    [ -n "$entry" ] || continue
    # -y is required anyway when stdout is not a TTY, which is the case under bootstrap.
    if "$cmd" plugin install "$entry" -y --scope user >/dev/null 2>&1; then
      echo "  $entry"
    else
      failed="$failed $entry"
    fi
  done < "$plugins"

  if [ -n "$failed" ]; then
    echo "could not install:$failed" >&2
    return 1
  fi
  echo "claude plugins installed (restart claude to load them)."
}
# Formatters neoformat drives. clang-format and shfmt come from the package lists;
# these three are pip-only or hopelessly stale there (apt ships black 21.12b0, which
# formats differently enough to churn every file it touches).
install_formatters() {
  if _is_mac; then
    for f in black isort docformatter; do brew install "$f" || true; done
    return 0
  fi

  command -v pip3 >/dev/null 2>&1 || sudo apt install -y python3-pip || return 1
  # --user keeps them out of the system python; .zshrc already has ~/.local/bin on PATH.
  pip3 install --user --upgrade black isort docformatter || return 1

  missing=""
  for f in black isort docformatter; do
    [ -x "$HOME/.local/bin/$f" ] || command -v "$f" >/dev/null 2>&1 || missing="$missing $f"
  done
  [ -z "$missing" ] || { echo "formatters missing after install:$missing" >&2; return 1; }
  echo "python formatters installed."
}
install_vscode() {
  # Returning 0 here is what hid a whole missing extension set: bootstrap reported
  # success while installing nothing, because install_gui had failed earlier.
  if ! command -v code >/dev/null 2>&1; then
    echo "code is not on PATH (did install_gui fail?)" >&2
    return 1
  fi

  # macOS stores user config under Library; point it at the tracked path.
  if _is_mac; then
    mac_dir="$HOME/Library/Application Support/Code/User"
    if [ ! -L "$mac_dir" ]; then
      rm -rf "$mac_dir"
      mkdir -p "$HOME/Library/Application Support/Code"
      ln -s "$HOME/.config/Code/User" "$mac_dir"
    fi
  fi

  failed=""
  while read -r ext; do
    [ -n "$ext" ] || continue
    code --install-extension "$ext" --force >/dev/null 2>&1 || failed="$failed $ext"
  done < "$YADM_DIR/vscode-extensions.txt"

  if [ -n "$failed" ]; then
    echo "could not install extensions:$failed" >&2
    return 1
  fi
  echo "vscode extensions installed."
}
# Work-only, so deliberately NOT in bootstrap — run it by hand when a job needs it:
#   source ~/.config/yadm/functions.sh && install_tailscale
# Tailscale is not in the Ubuntu archive, so use the official installer: it adds the
# apt repo, installs, and enables tailscaled. Login is interactive, so `tsu` is left
# to the user (see .aliases_work.zsh).
install_tailscale() {
  if _is_mac; then
    brew install --cask tailscale || true
    return 0
  fi

  if command -v tailscale >/dev/null 2>&1; then
    echo "tailscale already installed."
    return 0
  fi

  # `curl | sh` reports sh's status, so check the binary instead of the pipeline.
  curl -fsSL https://tailscale.com/install.sh | sh || true
  command -v tailscale >/dev/null 2>&1 || { echo "could not install tailscale." >&2; return 1; }
  echo "tailscale installed; run 'tsu' to log in."
}
