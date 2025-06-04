function gi() { curl -sLw "\n" https://www.toptal.com/developers/gitignore/api/$@ ;}

function note() {
  local filename="$(date +'%y_%m_%d').txt"
  vim "$filename"
}

ros2_record_mcap() {
  local topics=(
    "/cloud_reoriented"
    "/patchworkpp/ground"
    "/patchworkpp/nonground"
  )

  local user_prefix="$1"
  if [[ -z "$user_prefix" ]]; then
    echo -n "Enter a filename prefix (e.g., 'urban_drive'): "
    read user_prefix
    if [[ -z "$user_prefix" ]]; then
      echo "Filename prefix cannot be empty. Aborting."
      return 1
    fi
  fi

  local timestamp=$(date "+%Y%m%d_%H%M%S")
  local filename="${user_prefix}_${timestamp}"

  echo "\nRecording will be saved as: $filename"
  echo "Topics to be recorded:"
  for topic in "${topics[@]}"; do
    echo "  $topic"
  done

  echo -n "Press Enter to start recording..."
  read

  echo "Recording started. Press any key to stop..."

  ros2 bag record -o "$filename" --storage mcap "${topics[@]}" &
  local pid=$!

  read -sk1
  echo "Stopping recording..."

  kill -INT "$pid"
  wait "$pid"

  echo "Recording saved to $filename"
}

