Vagrant.configure("2") do |config|

  config.vm.box = "gyptazy/ubuntu22.04-arm64"

  config.vm.define "server" do |app|
    app.vm.hostname = "bare-server.test"
    app.vm.network :private_network, ip: "192.168.225.139"
  end
  
end
