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
  copypath
  fzf
	fzf-tab
  zsh-syntax-highlighting
  colored-man-pages
  command-not-found
  zsh-autosuggestions
)

command -v thefuck >/dev/null 2>&1 && eval "$(thefuck --alias)"

[ -x /home/linuxbrew/.linuxbrew/bin/brew ] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
export PATH="/usr/bin:$PATH"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

source $ZSH/oh-my-zsh.sh
source $HOME/.aliases.zsh
[ -f $HOME/.aliases_work.zsh ] && source $HOME/.aliases_work.zsh
source $HOME/.functions.zsh
[ -f $HOME/.zsh_work ] && source $HOME/.zsh_work
source $HOME/.ros.sh
[ -f $HOME/dev/ros2-aliases/ros2_utils.zsh ] && source $HOME/dev/ros2-aliases/ros2_utils.zsh


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="$HOME/.local/bin:$PATH"
