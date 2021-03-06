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
if [ "${GRIMOIRELAB_DEBUG:-false}" == "true" ]; then
    set -o xtrace
fi

source _functions.sh
sudo sysctl -w vm.max_map_count=262144
pkgs=""
if ! command -v docker; then
    pkgs+="docker"
fi
if ! command -v docker-compose; then
    pkgs+=" docker-compose"
fi
if [ -n "$pkgs" ]; then
    curl -fsSL http://bit.ly/install_pkg | PKG=$pkgs bash
fi
source cleanup.sh

_generate_projects_file

docker_compose_cmd="sudo docker-compose --file docker-compose.yml --file docker-compose.${GRIMOIRELAB_DEPLOY_TAG:-stable}.yml"
# Deployment
if [ "${GRIMOIRELAB_DEPLOY_MODE:-pull}" == "build" ]; then
    ${docker_compose_cmd} build --no-cache
else
    ${docker_compose_cmd} pull
fi
${docker_compose_cmd} up --scale arthurw="${GRIMOIRELAB_NUM_ARTHUR_WORKERS:-10}" --scale elasticsearch_node=5 --force-recreate --renew-anon-volumes --detach
