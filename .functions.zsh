function gi() { curl -sLw "\n" https://www.toptal.com/developers/gitignore/api/$@ ;}

create_docker_setup_ros() {
    # Create Dockerfile
    cat <<EOF > Dockerfile
# Use container registry for the base images
ARG BASE_IMAGE=
FROM BASE_IMAGE as 

ARG UID=1000
ARG GID=1000
# not an arg, because otherwise its a pain in the ass
ENV USERNAME=
ENV ROSWS=/home/${USERNAME}/ros_ws

# Add normal sudo-user to container, passwordless, taken from nacho's ros in docker
RUN addgroup --gid $GID $USERNAME \
    && adduser --disabled-password --gecos '' --uid $UID --gid $GID $USERNAME \
    && adduser $USERNAME sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && sed -i 's/required/sufficient/' /etc/pam.d/chsh \
    && touch /home/$USERNAME/.sudo_as_admin_successful



# Install some custom packages you need for the dockerfile
RUN apt update && apt upgrade -y

# install dependencies for hba docker
RUN apt-get update && apt-get install -y \
  && rm -rf /var/lib/apt/lists/*

# command to install with pip
RUN  pip install --user --upgrade --no-cache-dir


# Setup workdir

WORKDIR /home/${USERNAME}/
ENV HOME=/home/${USERNAME}
USER ${USERNAME}

# Do all your crap here


# some mandatory stuff

COPY ./entrypoint.sh /home/${USERNAME%}/
RUN chown -R ${USERNAME} ${WORKSPACE}
RUN chmod +x /home/${USERNAME}/entrypoint.sh
ENTRYPOINT ["/home/${USERNAME}/entrypoint.sh"]
CMD ["bash", "--login"]
EOF

    # Create docker-compose.yml
    cat <<EOF > docker-compose.yml
version: "3.7"
name: #name for this project (set same as target dockerfile)

volumes:
  bashhistory-<name_of_project>: {}

services:
  service-name:
    image: ${COMPOSE_PROJECT_NAME}              
    build:
      context: ./
      dockerfile: ./Dockerfile
      target: ${COMPOSE_PROJECT_NAME} 
      args:
        - USER_UID=${UID:-1000}
        - USER_GID=${GID:-1000}
    container_name: "" # container name
    volumes:
      - bashhistory-<name_of_project>:/cmd
      - /tmp/.X11-unix:/tmp/.X11-unix
      - ~/.Xauthority:/root/.Xauthority
      - $HOME:/host-home
    privileged: true
    user: ros
    network_mode: "host"
    tty: true
    # Make sure we only have to wait 1s when the container is stopped:
    stop_grace_period: 1s
EOF

    # Create entrypoint.sh
    cat <<EOF > entrypoint.sh
#!/bin/bash

# Print a message to indicate that the script is running
echo "Starting application..."

# Run the main application
exec "\$@"
EOF

    # Make entrypoint.sh executable
    chmod +x entrypoint.sh

    echo "Dockerfile, docker-compose.yml, and entrypoint.sh have been created."
}

