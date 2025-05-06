alias xopen='xdg-open'
alias xcopy='xclip -selection clipboard'
alias df='df -h -xsquashfs -xtmpfs -xdevtmpfs'
alias vim='nvim'
alias ydam='yadm'
alias gs="git status"
alias note='cd ~/projects/personal/notes'
alias c="clear"
alias rz="source ~/.zshrc"
alias ca="source ~/anaconda3/bin/activate"
alias da="conda deactivate"
alias ldd="tree -d -L 1"
# alias cat="batcat"

# Check if the OS is Unix-like

if [[ $(uname) == "Darwin" ]]; then
  alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
  alias cat="bat"

  # Directory aliases
  alias paper="cd ~/projects/personal/papers_to_read"
  alias rgbd="cd ~/projects/personal/rgbd_dataloader"
  alias work="cd ~/projects/work"
else
  alias cat="batcat"
fi

#kitty aliases
alias ssh="kitten ssh"

