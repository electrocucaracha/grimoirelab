# -*- mode: ruby -*-
# vi: set ft=ruby :

if ENV['no_proxy'] != nil or ENV['NO_PROXY']
  $no_proxy = ENV['NO_PROXY'] || ENV['no_proxy'] || "127.0.0.1,localhost"
  $subnet = "192.168.124"
  # NOTE: This range is based on vagrant-libvirt network definition CIDR 192.168.124.0/27
  (1..31).each do |i|
    $no_proxy += ",#{$subnet}.#{i}"
  end
  $no_proxy += ",10.0.2.15,redis,elasticsearch,kibiter,arthurd"
end
socks_proxy = ENV['socks_proxy'] || ENV['SOCKS_PROXY'] || ""

Vagrant.configure("2") do |config|
  config.vm.provider :libvirt
  config.vm.provider :virtualbox

  config.vm.box = "elastic/ubuntu-16.04-x86_64"
  config.vm.network :forwarded_port, guest: 5601, host: 5601
  config.vm.provision 'shell', privileged: false do |sh|
    sh.env = {
        'SOCKS_PROXY': "#{socks_proxy}",
        'GRIMOIRELAB_ORG': "openstack"
    }
    sh.inline = <<-SHELL
      cd /vagrant/
      ./postinstall.sh
    SHELL
  end 

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

  [:virtualbox, :libvirt].each do |provider|
    config.vm.provider provider do |p, override|
      p.cpus = 2
      p.memory = 8192
    end
  end
  config.vm.provider 'libvirt' do |v, override|
    v.nested = true
    v.cpu_mode = 'host-passthrough'
    v.management_network_address = "192.168.124.0/27"
    v.management_network_name = "grimoirelab-mgmt-net"
    v.random_hostname = true
  end
end
