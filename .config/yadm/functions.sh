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
    sudo chsh -s "$(command -v zsh)" "$USER" 2>/dev/null || chsh -s "$(command -v zsh)" || true
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
