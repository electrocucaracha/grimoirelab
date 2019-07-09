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
    sudo mkdir -p /root/.docker/
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
        sudo cp "$HOME/.docker/config.json" /root/.docker/config.json
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

# install_package() - Installs a specific RPM or Deb package
function install_package {
    # shellcheck disable=SC1091
    source /etc/os-release || source /usr/lib/os-release
    case ${ID,,} in
        *suse)
        INSTALLER_CMD="sudo -H -E zypper -q install -y --no-recommends"
        sudo zypper -n ref
        ;;

        ubuntu|debian)
        INSTALLER_CMD="sudo -H -E apt-get -y -q=3 install"
        sudo apt-get update
        ;;

        rhel|centos|fedora)
        PKG_MANAGER=$(command -v dnf || command -v yum)
        INSTALLER_CMD="sudo -H -E ${PKG_MANAGER} -q -y install"
        sudo "$PKG_MANAGER" updateinfo
        ;;
    esac
    ${INSTALLER_CMD} $1
}

# _install_jq() - Install a JSON processor
function _install_jq {
    if command -v jq; then
        return
    fi

    echo "Installing JSON processor..."
    install_package jq
}

# install_docker_compose() - Installs docker compose python module
function install_docker_compose {
    _install_docker
    if ! command -v python; then
        # shellcheck disable=SC1091
        source /etc/os-release || source /usr/lib/os-release
        case ${ID,,} in
            ubuntu|debian)
            install_package python-minimal
            ;;
        esac
    fi
    if ! command -v pip; then
        echo "Installing python package manager..."
        curl -sL https://bootstrap.pypa.io/get-pip.py | sudo python
    fi
    if ! command -v docker-compose; then
        echo "Installing docker-compose tool..."
        sudo -E pip install docker-compose==1.24.0
    fi
}
