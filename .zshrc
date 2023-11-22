[ -n $SSH_CONNECTION]  && ZSH_THEME="simple" || ZSH_THEME="simple"

DISABLE_AUTO_UPDATE="true"
ENABLE_CORRECTION="false"
HYPHEN_INSENSITIVE="true"
ZSH_TMUX_AUTOCONNECT="false"
ZSH_TMUX_AUTOQUIT="true"
ZSH_TMUX_AUTOSTART="false"

export ZSH="$HOME/.oh-my-zsh"
plugins=(
  git
	zsh-autocomplete
	z
  fzf
	zsh-syntax-highlighting
  colored-man-pages
  command-not-found
  zsh-autosuggestions
  ag)
source $ZSH/oh-my-zsh.sh
source $HOME/.aliases.zsh
source $HOME/.functions.zsh


eval $(thefuck --alias)



# Entry point for Depthai demo app, enables to run <depthai_launcher> in terminal
# export PATH=$PATH:/Users/dhagash/projects/depthai//depthai/entrypoint
# export PATH=$PATH:/Users/dhagash/projects/depthai/depthai/entrypoint
