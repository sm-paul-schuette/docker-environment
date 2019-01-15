#!/usr/bin/env bash

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
declare -t sudo_successful=1
sudo_active=$(sudo -S -v >/dev/null 2>&1 <<<""; echo $?)

function enter_sudo() {
    if [[ ${EUID} -ne 0 ]] && [[ ${sudo_active} -ne 0 ]]; then
        echo "The install-script needs root privileges."
        read -rsp "Please enter your password for sudo (will not be shown): " passw
        echo ""
        sudo_successful=$(sudo -S -v >/dev/null 2>&1 <<<"${passw}"; echo $?)
        if [[ ${sudo_successful} -ne 0 ]]; then
            echo "Command 'sudo' was not successful - exiting."
            exit 1
        fi
    fi
}

function exit_sudo() {
  if [[ ${sudo_active} -ne 0 ]] && [[ ${sudo_successful} -eq 0 ]];
    then echo 'exiting sudo for you'
    sudo -k
  fi
}
## make sure sudo does not survive this script
trap exit_sudo EXIT

enter_sudo

## place resolver
if [[ -d /etc/resolver ]]; then
  echo directory "/etc/resolver" already exists
else
  echo Creating directory "/etc/resolver"
  sudo mkdir -p /etc/resolver
fi

if [[ -f /etc/resolver/docker ]]; then
  echo resolver file for domain ".docker" already exists
else
   echo setting local dnsmasq as resolver for domain ".docker"
   cat ${SCRIPT_DIR}/dnsmasq.resolver.docker | sudo tee /etc/resolver/docker > /dev/null
fi
