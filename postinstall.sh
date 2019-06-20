#!/bin/bash
# SPDX-license-identifier: Apache-2.0
##############################################################################
# Copyright (c) 2019
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

set -o nounset
set -o pipefail
set -o xtrace

# _install_docker() - Download and install docker-engine
function _install_docker {
    local chameleonsocks_filename=chameleonsocks.sh

    if command -v docker; then
        return
    fi
    echo "Installing docker service..."
    curl -fsSL https://get.docker.com/ | sh

    if [ -n "${SOCKS_PROXY+x}" ]; then
        wget "https://raw.githubusercontent.com/crops/chameleonsocks/master/$chameleonsocks_filename"
        chmod 755 "$chameleonsocks_filename"
        socks_tmp="${SOCKS_PROXY#*//}"
        sudo ./$chameleonsocks_filename --uninstall
        sudo PROXY="${socks_tmp%:*}" PORT="${socks_tmp#*:}" ./$chameleonsocks_filename --install
        rm $chameleonsocks_filename
    fi
}

# install_docker_compose() - Installs docker compose python module
function install_docker_compose {
    _install_docker
    if ! command -v pip; then
        curl -sL https://bootstrap.pypa.io/get-pip.py | sudo python
    fi
    if ! command -v docker-compose; then
        echo "Installing docker-compose tool..."
        sudo -E pip install docker-compose==1.24.0
    fi
}

install_docker_compose
sudo sysctl -w vm.max_map_count=262144
sudo docker-compose up -d --scale arthurw=3
echo "Waiting for arthur daemon to start..."
until sudo docker-compose exec arthurd  grep "Serving on http://0.0.0.0:8080" /var/log/arthur.log; do
    printf '.'
    sleep 2
done
echo "Add initial tasks"
curl --noproxy "*" -H "Content-Type: application/json" --data @tasks.json http://10.5.1.4:8080/add
