# Docker development environment
Compilation of docker images used for development

## TL;DR
```
git clone https://github.com/sm-paul-schuette/docker-environment.git
cd docker-environment
./setup.sh
```
Point your browser to http://portainer.docker

## Contents
This project holds a set of docker-images that are useful for day-to-day development.

### [nginx-proxy](https://github.com/jwilder/nginx-proxy)
Simple reverse-proxy that allows automatic routing to running docker-containers.
Every container that has environment variable $VIRTUAL_HOST set and eiher exactly one port exposed *or* also $VIRTUAL_PORT set will be automatically
routed to by this container.

### [Portainer](https://github.com/portainer/portainer)
Clean UI to manage your docker containers, images, volumes, ...

Find the UI at http://portainer.docker

### [ssh-agent](https://github.com/nardeas/docker-ssh-agent) (needed on OSX only)
On OSX you cannot simply forward your authentication socket to a docker container to be able to e.g clone private repositories that you have access to. You don't want to copy your private key to all containers either. The solution is to add your keys only once to a long-lived ssh-agent container that can be used by other containers and stopped when not needed anymore.

If you need to clone a repo inside another container you can simply mount the agent:
```
  ~ $ docker run -it --hostname ssh-agent-mounted --volumes-from ssh-agent -e SSH_AUTH_SOCK=/.ssh-agent/socket ubuntu:latest bash
  root@ssh-agent-mounted:/# ls -F $SSH_AUTH_SOCK
  /.ssh-agent/socket=
  root@ssh-agent-mounted:/#
```

List all registered keys:
```
docker run --rm --volumes-from ssh-agent nardeas/ssh-agent ssh-add -L
```

## Usage
Clone this repo and run `setup.sh` to have the environment running.
The script interactively will create a `docker-compose.yml` file for you and add your private ssh-key to the ssh-agent running in container `ssh-agent`.


### Configuration
The script will ask for a place to store portainer data. This is mainly used for credentials, so you don't have to setup portainer over and over again.
The default choice should already be a sane place.

You can register a custom ssh-key to the ssh-agent by setting the environment variable DOCKER_SSH_AGENT_KEY before running `setup.sh`. Don't enter the full path, but just
the name of the file inside your `~/.ssh` folder. If you want to register a file from a completely different place refer please refer to the [original repo](https://github.com/nardeas/docker-ssh-agent).
