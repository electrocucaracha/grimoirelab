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

source _functions.sh
source cleanup.sh

_generate_projects_file
sudo sysctl -w vm.max_map_count=262144

docker_compose_cmd="sudo docker-compose --file docker-compose.yml --file docker-compose.${GRIMOIRELAB_DEPLOY_TAG:-stable}.yml"
# Deployment
if [ "${GRIMOIRELAB_DEPLOY_MODE:-pull}" == "build" ]; then
    ${docker_compose_cmd} build --no-cache
else
    ${docker_compose_cmd} pull
fi
${docker_compose_cmd} up --scale arthurw=10 --force-recreate --renew-anon-volumes --detach
