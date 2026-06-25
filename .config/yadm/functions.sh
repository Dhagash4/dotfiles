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
install_gui()      { echo "TODO task 3"; }
install_ohmyzsh()  { echo "TODO task 4"; }
install_nvim()     { echo "TODO task 5"; }
install_vscode()   { echo "TODO task 6"; }
