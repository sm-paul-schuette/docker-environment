# Docker development environment
Compilation of docker images used for development

This project hold a set of docker-images that are useful for daily development.

## Contents
### [nginx-proxy](https://github.com/jwilder/nginx-proxy)
Simple reverse-proxy that allows automatic routing to running docker-containers.

### [Portainer](https://github.com/portainer/portainer)
Clean UI to manage your docker containers, images, volumes

### [ssh-agent](https://github.com/nardeas/docker-ssh-agent) (needed on OSX only)
On OSX you cannot simply forward your authentication socket to a docker container to be able to e.g clone private repositories that you have access to. You don't want to copy your private key to all containers either. The solution is to add your keys only once to a long-lived ssh-agent container that can be used by other containers and stopped when not needed anymore.
