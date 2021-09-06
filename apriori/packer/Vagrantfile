#MIT License
#Copyright (c) 2017-2018 phR0ze
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.

nodes = [
  <%=nodes%>
]

Vagrant.configure("2") do |config|
  config.vm.synced_folder(".", "/vagrant", disabled:true)

  # Configure each node
  #-----------------------------------------------------------------------------
  nodes.each do |node|
    config.vm.define node[:host] do |conf|
      conf.vm.box = node[:box]
      conf.vm.hostname = node[:host]

      # Custom VirtualBox settings
      #-------------------------------------------------------------------------
      conf.vm.provider :virtualbox do |vbox|
        vbox.name = node[:host]
        vbox.cpus = node[:cpus]
        vbox.memory = node[:ram]
        vbox.customize(["modifyvm", :id, "--vram", node[:vram]])
        vbox.customize(["modifyvm", :id, "--accelerate3d", node[:v3d]])

        # Configure Audio
        audio_driver = RUBY_PLATFORM == 'x86_64-linux' ? 'alsa' : 'dsound'
        vbox.customize(["modifyvm", :id, "--audio", audio_driver, "--audiocontroller", "ac97"])

        # Configure Networking
        vbox.customize(["modifyvm", :id, "--nic1", "nat"])
        vbox.customize(["modifyvm", :id, "--nic2", "hostonly"])
        vbox.customize(["modifyvm", :id, "--hostonlyadapter2", node[:net]])
      end

      # Custom VM provisioning
      #-------------------------------------------------------------------------
      conf.vm.provision :shell do |script|

        # Setup proxy vars and add deployed nodes to the no_proxy
        proxy, no_proxy = nil
        if node[:proxy]
          proxy = node[:proxy]
          no_proxy = node[:no_proxy] || "localhost,127.0.0.1"
          _nodes = nodes.map{|x| x[:ip][0..x[:ip].index('/')-1]}.select{|x| !no_proxy.include?(x)}
          no_proxy += ",#{_nodes * ','}" if _nodes.any?
        end

        # Set the bash script to execute for configuration
        script.args = [node[:ip], proxy.to_s, no_proxy.to_s, node[:ipv6].to_s]
        script.inline = <<-SHELL
          echo "Configuring host-only static ip address"
          echo "VM Static IP: ${1}"
          echo -e "[Match]\\nName=enp0s8 eth0\\n" > /etc/systemd/network/10-static.network
          echo -e "[Network]\\nAddress=${1}\\nIPForward=kernel" >> /etc/systemd/network/10-static.network

          if [ x"${2}" != x"" ]; then
            echo "Configuring proxy settings"
            echo "Proxy=${2}"
            echo "No Proxy=${3}"
            /opt/<%=distro%>/bin/setproxy enable ${2} ${3} &>/dev/null
          else
            echo "No proxy settings required"
          fi

          if [ x"${4}" != x"" ]; then
            echo "Enabling IPv6"
            sed -i -e "s/ ipv6.disable=1//" /boot/syslinux/syslinux.cfg
          else
            echo "Leaving IPv6 disabled"
          fi

          echo "Done configuring vagrant box"
          SHELL
      end

    end
  end
end

# vim: ft=ruby:ts=2:sw=2:sts=2
