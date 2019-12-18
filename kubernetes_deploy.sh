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
    export KRD_DEBUG="true"
fi

if ! command -v kubectl; then
    KRD_ACTIONS=("install_k8s" "install_rook")
    KRD_ACTIONS_DECLARE=$(declare -p KRD_ACTIONS)
    export KRD_ACTIONS_DECLARE
    curl -fsSL https://raw.githubusercontent.com/electrocucaracha/krd/master/aio.sh | bash
    for file in cluster filesystem object pool; do
        kubectl apply -f "https://raw.githubusercontent.com/rook/rook/master/cluster/examples/kubernetes/ceph/${file}-test.yaml"
    done
fi

#_generate_projects_file

if ! helm ls | grep -e redis-db; then
    helm install stable/redis --name redis-db --values redis_values.yaml
fi

if ! helm ls | grep -e elasicsearch-db; then
    helm install stable/elasticsearch --name elasicsearch-db --values elasticsearch_values.yaml
fi
