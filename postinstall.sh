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

source _installers.sh

install_docker_compose
sudo sysctl -w vm.max_map_count=262144
if [ ! -f conf/projects.json ]; then
    _install_jq
    projects="{\"$GRIMOIRELAB_ORG\": { \"git\": [ "
    if [ -n "${GRIMOIRELAB_ORG+x}" ] ; then
        repos_page=1
        while true; do
            repos_counter=0
            for repo in $(curl -s "https://api.github.com/orgs/${GRIMOIRELAB_ORG}/repos?per_page=100&page=$repos_page" | jq ".[].html_url"); do
                echo "Adding $repo to projects.json"
                projects+="${repo},"
                ((repos_counter+=1))
            done
            ((repos_page+=1))
            [[ $repos_counter == 100 ]] || break
        done
    fi
    echo "${projects::-1} ] } }" | jq . | tee "conf/projects.json"
fi

source cleanup.sh

docker_compose_cmd="sudo docker-compose --file docker-compose.yml --file docker-compose.${GRIMOIRELAB_DEPLOY_TAG:-stable}.yml"
# Deployment
if [ "${GRIMOIRELAB_DEPLOY_MODE:-pull}" == "build" ]; then
    ${docker_compose_cmd} build --no-cache
else
    ${docker_compose_cmd} pull
fi
${docker_compose_cmd} up --scale arthurw=10 --force-recreate --renew-anon-volumes --detach
