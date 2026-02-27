#Credits: Igancio Vizzo (https://github.com/nachovizzo/dotfiles/blob/main/.ros.sh)

#!/usr/bin/env zsh
# Fix zsh autocomplete in zsh
# https://github.com/ros2/ros2cli/issues/534#issuecomment-957516107

export ROS_DISTRO=humble 
export ROS_DOMAIN_ID=0
# Fix zsh autocomplete in zsh
if [ -f /opt/ros/${ROS_DISTRO}/setup.zsh ]; then
  source /opt/ros/${ROS_DISTRO}/setup.zsh
  eval "$(register-python-argcomplete3 ros2)"
  eval "$(register-python-argcomplete3 colcon)"
fi
