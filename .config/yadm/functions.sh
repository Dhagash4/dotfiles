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
install_ohmyzsh()  { echo "TODO task 4"; }
install_nvim()     { echo "TODO task 5"; }
install_vscode()   { echo "TODO task 6"; }
