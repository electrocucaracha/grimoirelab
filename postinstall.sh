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
    sudo mkdir -p /etc/systemd/system/docker.service.d/
    mkdir -p "$HOME/.docker/"
    sudo usermod -aG docker "$USER"

    if [ -n "${HTTP_PROXY:-}" ] || [ -n "${HTTPS_PROXY:-}" ] || [ -n "${NO_PROXY:-}" ]; then
        config="{ \"proxies\": { \"default\": { "
        if [ -n "${HTTP_PROXY:-}" ]; then
            echo "[Service]" | sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf
            echo "Environment=\"HTTP_PROXY=$HTTP_PROXY\"" | sudo tee --append /etc/systemd/system/docker.service.d/http-proxy.conf
            config+="\"httpProxy\": \"$HTTP_PROXY\","
        fi
        if [ -n "${HTTPS_PROXY:-}" ]; then
            echo "[Service]" | sudo tee /etc/systemd/system/docker.service.d/https-proxy.conf
            echo "Environment=\"HTTPS_PROXY=$HTTPS_PROXY\"" | sudo tee --append /etc/systemd/system/docker.service.d/https-proxy.conf
            config+="\"httpsProxy\": \"$HTTPS_PROXY\","
        fi
        if [ -n "${NO_PROXY:-}" ]; then
            echo "[Service]" | sudo tee /etc/systemd/system/docker.service.d/no-proxy.conf
            echo "Environment=\"NO_PROXY=$NO_PROXY\"" | sudo tee --append /etc/systemd/system/docker.service.d/no-proxy.conf
            config+="\"noProxy\": \"$NO_PROXY\","
        fi
        echo "${config::-1} } } }" | tee "$HOME/.docker/config.json"
        sudo systemctl daemon-reload
        sudo systemctl restart docker
    elif [ -n "${SOCKS_PROXY:-}" ]; then
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
sudo docker-compose down --remove-orphans
sudo rm -rf logs/*
sudo docker-compose up -d --scale arthurw=3
