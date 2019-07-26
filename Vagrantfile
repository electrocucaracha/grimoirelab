# -*- mode: ruby -*-
# vi: set ft=ruby :

if ENV['no_proxy'] != nil or ENV['NO_PROXY']
  $no_proxy = ENV['NO_PROXY'] || ENV['no_proxy'] || "127.0.0.1,localhost"
  # NOTE: This range is based on grimoirelab-mgmt-net network definition CIDR 192.168.124.5/30
  (4..7).each do |i|
    $no_proxy += ",192.168.124.#{i}"
  end
  $no_proxy += ",arthurd,redis,elasticsearch,kibiter"
end
socks_proxy = ENV['socks_proxy'] || ENV['SOCKS_PROXY'] || ""

Vagrant.configure("2") do |config|
  config.vm.provider :libvirt
  config.vm.provider :virtualbox
  config.vm.box = "elastic/ubuntu-16.04-x86_64"
  if ENV['http_proxy'] != nil and ENV['https_proxy'] != nil
    if not Vagrant.has_plugin?('vagrant-proxyconf')
      system 'vagrant plugin install vagrant-proxyconf'
      raise 'vagrant-proxyconf was installed but it requires to execute again'
    end
    config.proxy.http     = ENV['http_proxy'] || ENV['HTTP_PROXY'] || ""
    config.proxy.https    = ENV['https_proxy'] || ENV['HTTPS_PROXY'] || ""
    config.proxy.no_proxy = $no_proxy
    config.proxy.enabled = { docker: false }
  end

  config.vm.provider 'libvirt' do |v, override|
    v.nested = true
    v.cpu_mode = 'host-passthrough'
    v.management_network_address = "192.168.124.5/30"
    v.management_network_name = "grimoirelab-mgmt-net"
    v.random_hostname = true
  end

  # Docker compose deployment
  config.vm.define :docker_compose, autostart: false do |docker_compose|
    docker_compose.vm.network :forwarded_port, guest: 5601, host: 5601
    docker_compose.vm.synced_folder './', '/vagrant',
      rsync__args: ["--verbose", "--archive", "--delete", "-z"]
    docker_compose.vm.provision 'shell', privileged: false do |sh|
      sh.env = {
        'SOCKS_PROXY': "#{socks_proxy}",
        'GRIMOIRELAB_DEBUG': "true",
        'GRIMOIRELAB_NUM_ARTHUR_WORKERS': 3,
        'GRIMOIRELAB_DEPLOY_MODE': "build",
        'GRIMOIRELAB_DEPLOY_TAG': "latest"
      }
      sh.inline = <<-SHELL
        cd /vagrant/
        cat <<EOL > /vagrant/conf/projects.json
        {
          "openstack": {
            "git": [
              "https://github.com/openstack/keystone",
              "https://github.com/openstack/nova",
              "https://github.com/openstack/neutron",
              "https://github.com/openstack/cinder",
              "https://github.com/openstack/glance"
            ]
          }
        }
EOL
        ./docker-compose_deploy.sh | tee deploy.log
      SHELL
    end
    [:virtualbox, :libvirt].each do |provider|
      docker_compose.vm.provider provider do |p, override|
        p.cpus = 2
        p.memory = 8192
      end
    end
  end

  # Kubernetes deployment
  config.vm.define :kubernetes, autostart: false do |kubernetes|
    kubernetes.vm.provision 'shell', privileged: false do |sh|
      sh.env = {
        'KRD_DEBUG': 'true'
      }
      sh.inline = <<-SHELL
        curl -fsSL https://raw.githubusercontent.com/electrocucaracha/krd/master/aio.sh | bash
      SHELL
    end
    [:virtualbox, :libvirt].each do |provider|
      kubernetes.vm.provider provider do |p, override|
        p.cpus = 8
        p.memory = 16384
      end
    end
  end
end
