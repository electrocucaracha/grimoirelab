.. Copyright 2019
   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at
        http://www.apache.org/licenses/LICENSE-2.0
   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

******************
Deployment Methods
******************

This document provides information about the different ways to deploy
this project. Every method can be used for testing different phases
of the development of the project.

Containers with docker-compose
##############################

This method uses the current machine for deploying this project.
`Docker Compose project <https://docs.docker.com/compose/>`_ allows to
setup multiple containers and their configuration values. The 
*docker-compose_deploy.sh* bash script provides instructions for
cleaning up resources and start new ones. The
**GRIMOIRELAB_NUM_ARTHUR_WORKERS** environment variable specifies the
number of Arthur workers that is going to be created.

.. code-block:: bash

    $ GRIMOIRELAB_NUM_ARTHUR_WORKERS=10 ./docker-compose_deploy.sh

.. note::  This script can be executed multiple times.

Virtual Machines with vagrant
#############################

This project provides a *Vagrantfile* to automate the 
provisioning process on a Virtual Machines. The *setup.sh* bash script
provides the Linux instructions to install dependencies required for
its usage. This script supports two Virtualization technologies
(Libvirt and VirtualBox). The following instruction installs and
configures the Libvirt provider.

.. code-block:: bash

    $ ./setup.sh -p libvirt

Once Vagrant is installed, it's possible to provision a Virtual
Machine:

.. code-block:: bash

    $ vagrant up docker_compose

Containers in a Bare-metal machine
##################################

It's possible to deploy GrimoireLab services on a Bare-metal machines.
The *all-in-one.sh* bash script installs the dependencies required for
cloning the repository and execute the *docker-compose_deploy.sh* bash
script with its default options.

Virtual Machines on a public cloud with terraform
#################################################

The Terraform configuration files provided by this project launch 
multiple AWS EC2 instances, these instanc	es are based on the number of
GitHub organizations specified in the *variables.tf* file. These 
terraform files require to install the `terraform` client previously,
for more information visit the `official site <https://learn.hashicorp.com/terraform/getting-started/install#installing-terraform>`_.

.. code-block:: bash

    $ terraform init
    $ terraform apply -auto-approve
