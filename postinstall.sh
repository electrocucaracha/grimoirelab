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
    if command -v docker; then
        return
    fi
    curl -fsSL https://get.docker.com/ | sh

    sudo mkdir -p /etc/systemd/system/docker.service.d/
    mkdir -p "$HOME/.docker/"
    config="{ \"proxies\": { \"default\": { "
    if [[ ${HTTP_PROXY+x} = "x" ]]; then
        echo "[Service]" | sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf
        echo "Environment=\"HTTP_PROXY=$HTTP_PROXY\"" | sudo tee --append /etc/systemd/system/docker.service.d/http-proxy.conf
        config+="\"httpProxy\": \"$HTTP_PROXY\","
    fi
    if [[ ${HTTPS_PROXY+x} = "x" ]]; then
        echo "[Service]" | sudo tee /etc/systemd/system/docker.service.d/https-proxy.conf
        echo "Environment=\"HTTPS_PROXY=$HTTPS_PROXY\"" | sudo tee --append /etc/systemd/system/docker.service.d/https-proxy.conf
        config+="\"httpsProxy\": \"$HTTPS_PROXY\","
    fi
    if [[ ${NO_PROXY+x} = "x" ]]; then
        echo "[Service]" | sudo tee /etc/systemd/system/docker.service.d/no-proxy.conf
        echo "Environment=\"NO_PROXY=$NO_PROXY\"" | sudo tee --append /etc/systemd/system/docker.service.d/no-proxy.conf
        config+="\"noProxy\": \"$NO_PROXY\","
    fi
    echo "${config::-1} } } }" | tee "$HOME/.docker/config.json"
    sudo systemctl daemon-reload
    sudo systemctl restart docker
}

# install_docker_compose() - Installs docker compose python module
function install_docker_compose {
    _install_docker
    if ! command -v pip; then
        curl -sL https://bootstrap.pypa.io/get-pip.py | sudo python
    fi
    if ! command -v docker-compose; then
        sudo -E pip install docker-compose
    fi
}

install_docker_compose
sudo docker-compose up -d
echo "Waiting for arthurd to start..."
until sudo docker exec vagrant_arthurd_1 grep "Serving on http://0.0.0.0:8080" /var/log/arthur.log; do
    printf '.'
    sleep 2
done
curl --noproxy "*" -H "Content-Type: application/json" --data @tasks.json http://10.5.1.4:8080/add
