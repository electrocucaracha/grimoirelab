# GrimoireLab Cloud-Native

[![Build Status](https://travis-ci.org/electrocucaracha/grimoirelab.png)](https://travis-ci.org/electrocucaracha/grimoirelab)

This project pretends to separate the [GrimoireLab components][1] in
microservices. This is an initial attempt to move it to Cloud-Native
architecture.

## Deployment

### Virtual Machine

This project provides a [Vagrant file](Vagrantfile) for automate the 
provisioning process in a Virtual Machines. The setup bash script
contains the Linux instructions for installing its dependencies 
required for its usage. This script supports two Virtualization
technologies (Libvirt and VirtualBox). The following instruction 
installs and configures the Libvirt provider.

    $ ./setup.sh -p libvirt

Once Vagrant is installed, it's possible to provision a Virtual
Machine:

    $ vagrant up

### Bare Metal

It's possible to deploy GrimoireLab services on a Bare Metal machine.
The [post-install script](postinstall.sh) installs dependencies
required for the Docker-Compose execution. _This script can be
executed multiple times._

[![asciicast](https://asciinema.org/a/WwaPw46d6VO8WVd2eoSoMpD4Z.svg)](https://asciinema.org/a/WwaPw46d6VO8WVd2eoSoMpD4Z)

## License

Apache-2.0

[1]: https://chaoss.github.io/grimoirelab-tutorial/basics/components.html#components
