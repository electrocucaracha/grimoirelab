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

sudo sfdisk /dev/xvdh --no-reread << EOF
;
EOF
sudo mkfs -t ext4 /dev/xvdh1
mkdir -p /var/lib/docker/
sudo mount /dev/xvdh1 /var/lib/docker/
echo "/dev/xvdh1 /var/lib/docker/           ext4    errors=remount-ro,noatime,barrier=0 0       1" | sudo tee --append /etc/fstab
curl -fsSL https://raw.githubusercontent.com/electrocucaracha/grimoirelab/master/all-in-one.sh | GRIMOIRELAB_ORG=${org} USER=${user} HOME=${home} bash
