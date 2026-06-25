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
