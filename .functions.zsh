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

copy_compile_commands() {
    local workspace_dir="${PWD}"
    
    # Find the package name from package.xml
    if [[ -f "package.xml" ]]; then
        local pkg_name=$(grep -oP '(?<=<name>)[^<]+' package.xml | head -1)
        
        # Find the ws root by looking for build directory
        local ws_root="${workspace_dir}"
        while [[ ! -d "${ws_root}/build" ]] && [[ "${ws_root}" != "/" ]]; do
            ws_root=$(dirname "${ws_root}")
        done
        
        local build_dir="${ws_root}/build/${pkg_name}"
        
        if [[ -f "${build_dir}/compile_commands.json" ]]; then
            cp "${build_dir}/compile_commands.json" "${workspace_dir}/"
            echo "✓ Copied compile_commands.json from ${build_dir} to ${workspace_dir}"
        else
            echo "✗ compile_commands.json not found in ${build_dir}"
            echo "  Make sure CMAKE_EXPORT_COMPILE_COMMANDS is ON in your CMakeLists.txt"
        fi
    else
        echo "✗ package.xml not found. Are you in a ROS2 package directory?"
    fi
}
