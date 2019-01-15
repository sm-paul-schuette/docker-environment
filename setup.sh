#!/usr/bin/env bash

DOCKER_SSH_AGENT_KEY=${DOCKER_SSH_AGENT_KEY:-id_rsa}

show_help() {
  printf "Setup local development docker-containers"
  printf "\n\n"
  printf "Starts \n"
  printf "  * Portainer\n"
  printf "  * ssh-agent\n"
  printf "  * nginx-proxy\n"
  printf "  * dnsmasq\n"
  printf "\n"
  printf "and adds the ssh-key defined in \$DOCKER_SSH_AGENT_KEY (${DOCKER_SSH_AGENT_KEY}) to the ssh-agent"
  printf "\n\n"
  exit
}

[ "${1}" = "-h" ] || [ "${1}" = "--help" ] && \
  show_help

if [[ ! -f "docker-compose.yml" ]]; then
  PORTAINER_DEFAULT_STORAGE="~/.portainer/storage"
  printf "Setting up docker-environment\n\n"
  printf "Portainer needs a storage for it's internal database.\n"
  printf "Please enter a location [${PORTAINER_DEFAULT_STORAGE}]: "
  read PORTAINER_STORAGE
  PORTAINER_STORAGE=${PORTAINER_STORAGE:-${PORTAINER_DEFAULT_STORAGE}}
  cp docker-compose.yml.dist docker-compose.yml
  if [[ "${PORTAINER_STORAGE}" != "${PORTAINER_DEFAULT_STORAGE}" ]]; then
    sed_expression="s/$(echo ${PORTAINER_DEFAULT_STORAGE}|sed 's_/_\\/_g')/$(echo ${PORTAINER_STORAGE}|sed 's_/_\\/_g')/g"
    sed -i "" -e ${sed_expression} docker-compose.yml
  fi
fi

if [[ ! -f $(pwd)/.env ]]; then
  echo -n COMPOSE_PROJECT_NAME=php_backend > .env
fi

printf "Starting containers\n"
docker-compose up -d
printf "\n"
if [ -f ~/.ssh/${DOCKER_SSH_AGENT_KEY} ]; then
  printf "Adding your key (~/.ssh/${DOCKER_SSH_AGENT_KEY}) to ssh-agent\n"
else
  printf "Private key '~/.ssh/${DOCKER_SSH_AGENT_KEY}' not found. Is \$DOCKER_SSH_AGENT_KEY set correctly (\$DOCKER_SSH_AGENT_KEY=${DOCKER_SSH_AGENT_KEY})?\n"
fi
docker run --rm -v ${HOME}/.ssh:/.ssh:ro --volumes-from=ssh-agent -it nardeas/ssh-agent ssh-add .ssh/${DOCKER_SSH_AGENT_KEY}
printf "Following keys are now present:\n"
docker run --rm --volumes-from ssh-agent nardeas/ssh-agent ssh-add -L

if [[ "$OSTYPE" == "darwin"* ]]; then
   echo ""
   echo Installing custom resolver to /etc/resolver for ".docker" domain
   echo ""
  ./dnsmasq/osx_add_resolver.sh
fi
