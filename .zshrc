if [ -n "$SSH_CONNECTION" ]; then
    ZSH_THEME="simple"
elif [[ -f /.dockerenv ]]; then
    ZSH_THEME="gnzh"
else
    ZSH_THEME="simple"
fi

DISABLE_AUTO_UPDATE="true"
ENABLE_CORRECTION="false"
HYPHEN_INSENSITIVE="true"
ZSH_TMUX_AUTOCONNECT="false"
ZSH_TMUX_AUTOQUIT="true"
ZSH_TMUX_AUTOSTART="false"

export ZSH="$HOME/.oh-my-zsh"
plugins=(
  git
	z
  fzf
	fzf-tab
  zsh-syntax-highlighting
  colored-man-pages
  command-not-found
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh
source $HOME/.aliases.zsh
source $HOME/.functions.zsh
source $HOME/.ros.sh

eval $(thefuck --alias)

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
# if command -v brew &>/dev/null; then
#   eval "$($(command -v brew) shellenv)"
# fi

