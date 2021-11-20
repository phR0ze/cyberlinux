Networking
====================================================================================================
<img align="left" width="48" height="48" src="../../art/logo_256x256.png">
Documenting various networking technologies
<br><br>

### Quick links
* [.. up dir](..)
* [BlueMan](bluMan)
* [Firefox](firefox)
* [iptables](#iptables)
* [DNS](#dns)
  * [DNS commands](#dns-commands)
    * [DNS status](#dns-status)
    * [DNS lookup](#dns-lookup)
    * [DNS flush](#dns-flush)
  * [DNS routing](#dns-routing)
    * [Default Route](#default-route)
    * [Add domain route](#add-domain-route)
    * [/etc/resolv.conf](#etc-resolv-conf)
  * [Nameservers](#nameservers)
    * [Quad9 DNS](#quad9-dns)
    * [Cloudflare DNS](#cloudflare-dns)
    * [Google DNS](#google-dns)
    * [DNSSEC Validation Failures](#dnssec-validation-failures)
* [Network Interfaces](#network-interfaces)
  * [Bind to NIC](#bind-to-nic)
  * [Configure Multiple IPs](#configure-multiple-ips)
* [Network Manager](#network-manager)
  * [Install](#install-network-manager)
  * [Configure](#configure-network-manager)
  * [Keyfile Configs](#keyfile-configs)
  * [Network Manager and resolved](#network-manager-and-resolved)
* [NFS Shares](#nfs-shares)
  * [NFS Client Config](#nfs-server-config)
  * [NFS Server Config](#nfs-server-config)
  * [systemd-networkd-wait-online timing out](#systemd-networkd-wait-oneline-timing-out)
* [Remoting](#remoting)
  * [Barrier](#barrier)
  * [Teamviewer](#teamviewer)
  * [Zoom](#zoom)
* [SSH](#ssh)
  * [Port Forwarding](#ssh-port-forwarding)
* [sshuttle](#sshuttle)
* [systemd-networkd](#systemd-networkd)
  * [DHCP Networking](#dhcp-networking-systemd-networkd)
  * [Static Networking](#static-networking-systemd-networkd)
  * [Wifi Networking](#wifi-networking-systemd-networkd)
* [VPNs](#vpns)
  * [OpenConnect](#openconnect)
  * [OpenVPN](#openvpn)
  * [Split DNS Resolution](#split-dns-resolution)
* [WireGuard](#wireguard)
  * [WireGuard Client](#wireguard-client)
  * [WireGuard Server](#wireguard-server)

# iptables <a name="iptables"/></a>
`netfilter` controls access to and from the network stack at the Linux kernel module level. The
primary command line tool for managing netfilter hooks has been iptables rulesets. However since the
syntax needed to invoke those rules is complicated various user friendly tols like `ufw` and
`firewalld` have been created to simplify this.

Pro tips:
* rules are order specific later rules taking priority
* manually applied rules with `sudo iptables` are applied immediately
* iptable rules don't persist by default
* `sudo iptables -S` - list out current iptables

## iptables reset <a name="iptables-reset"/></a>
```bash
$ sudo systemctl restart iptables
```

## kiosk <a name="kiosk"/></a>
To illustrate iptables let's imagine we want to setup a Kiosk for a local school. The intent is that
students would be able to use a browser in a limited way to complete school related work. The kiosks
would need access to `ixl.com`. To keep the example simple we'll ignore all other protocols and
simply focus on `HTTP` and `HTTPS` over ports `80` and `443` and only concern ourselves with outbound
connections ignoring inbound.

This simple set of rules says to drop all outbound traffic on port 80 or 443 except to `ixl.com`:
```bash
sudo iptables -A OUTPUT -p tcp -d ixl.com --dport 80 -j ACCEPT
sudo iptables -A OUTPUT -p tcp -d ixl.com --dport 443  -j ACCEPT
sudo iptables -A OUTPUT -p tcp --dport 80 -j DROP
sudo iptables -A OUTPUT -p tcp --dport 443 -j DROP
```

* `-A` - indicates were adding a rule
* `OUTPUT` - indicates the rule should be part of the output chain
* `-p tcp` - indicates that this rule will apply only to packets using the TCP protocol
* `-d ixl.com` - indicates the destination
* `-j ACCEPT` - indicates the action to take
* `--dport 80` - indicates requests bound for destination port 80

# DNS <a name="dns"/></a>
[Arch Linux Wiki on Resolved](https://wiki.archlinux.org/index.php/Systemd-resolved#Setting_DNS_servers)
[Arch Linux Wiki on nameservers](https://wiki.archlinux.org/index.php/Alternative_DNS_services)
Systemd's `resolved` service configured it's Fallback DNS by default to use Cloudflare then Quad9 then
Google so that DNS will always work.

## DNS commands <a name="dns-commands"/></a>

### DNS status <a name="dns-status"/></a>
```bash
$ resolvectl status
```

### DNS lookup <a name="dns-lookup"/></a>
```bash
$ resolvectl query archlinux.org
```

### DNS flish <a name="dns-flush"/></a>
```bash
$ sudo resolvectl flush-caches
```

## DNS routing <a name="dns-routing"/></a>

[systemd-resolved and VPNs](https://systemd.io/RESOLVED-VPNS/)
There are two flavors of domains attached to a network interface: `routing domains` and `search 
domains`. They both specify that a given domain and any subdomains are appropriate for that 
interface. Search domains have the additional function that single-label names are suffixed with taht 
search domain before being resolved e.g. `server` would resolve to `server.example.com` for the 
search domain of `example.com`. In ***systemd-resolved*** config files, routing domains are prefixed 
with the tilda `~` character.

**Example:**  
Your VPN interface `tun0` has a search domain of `private.company.com` and a routing domain of 
`~company.com`. If you ask for `mail.private.company.com` it is matched by both domains and will be 
routed to `tun0`. Additionally requests for `www.company.com` would match the routing domain and be 
routed over `tun0` as well.

Determine current domain routing with:
```bash
$ resolvectl domain
Global:
Link 2 (eno1):
Link 18 (tun0): company.com
```

In the domain routing list above anything ending in `company.com` would resolve over the `tun0` link. 
And you can check the name servers that will be used per link as well.
```bash
$ resolvectl dns
Global: 1.1.1.1 1.0.0.1
Link 2 (eno1): 1.1.1.1 1.0.0.1
Link 18 (tun0): 10.45.248.15 10.38.5.26
```

Configure DNS (for all links):
```bash
# Edit resolved config
$ cat /etc/systemd/resolved.conf
[Resolve]
DNS=1.1.1.1 1.0.0.1
FallbackDNS=8.8.8.8 8.8.4.4

# Restart service
$ sudo systemctl restart systemd-resolved
```

### Debug dns <a name="debug-dns"/></a>
1. Check the logs
   ```bash
   $ journalctl -u systemd-resolved -b --no-pager
   # or 
   $ journalctl -u systemd-resolved --since="-2 minutes"
   -- Journal begins at Thu 2021-09-16 21:39:04 MDT, ends at Sat 2021-11-20 15:41:19 MST. --
   Nov 20 15:39:29 main4 systemd-resolved[8699]: Using degraded feature set UDP instead of TCP for DNS server 8.8.8.8.
   Nov 20 15:39:35 main4 systemd-resolved[8699]: Using degraded feature set TCP instead of UDP for DNS server 8.8.8.8.
   ```

### Default Route <a name="default-route"/></a>
The `default-route` property is a simple boolean value that may be set on an interface to indicate 
that any DNS lookup for which no matching routing or search domains exist are routed to this 
interfaces. If set to `false` then the DNS servers on this interface are not considered for routing 
lookups except for the ones matched with their searching/routing domains. Finally an interface that 
doesn't have this property is automatically considered for all lookups if a match has not been found 
yet.

### Add domain route <a name="add-domain-route"/></a>
In order to get all traffic for `company.com` to resolve over the `tun0` interface you'd need to 
configure a routing domain of `~company.com`. To further only consider this route for `company.com` 
traffice and not other traffice you'd need to add the `default-route: false` property.

**resolvectl** provides a wrapper around the `D-Bus` and can be used to instruct `systemd-resolved` 
dynamically rather than updating the config file statically.
```bash
# Set the routing domains to use
$ sudo resolvectl domain tun0 '~foo1.company.com' '~foo2.company.com'

# Set the interface to not be considered except for routing domain matches
$ sudo resolvectl default-route tun0 false

# Set the nameserver to use excplicitly
$ sudo resolvectl dns tun0 192.0.2.1
```

### /etc/resolv.conf <a name="etc-resolv-conf"/></a>
Some older software still uses `/etc/resolv.conf` directly. To plug this older mechanism into the 
newer `sytemd-resolved` system you need to setup a link to the resolved stub
```bash
$ sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
```

## Nameservers <a name="nameservers"/></a>

### Cloudflare DNS <a name="cloudflare-dns"/></a>
[Cloudflare's DNS](https://blog.cloudflare.com/announcing-1111/) heralded as the Internet's fastest,
privacy-first consumer DNS service.

* ***1.1.1.1***
* ***1.0.0.1***

### Quad9 DNS <a name="quad9-dns"/></a>
[Quad9's DNS](https://quad9.net/) is a DNS service founed by IBM and a few others with the primary
unique feature of a malicious blocklist.

* ***9.9.9.9***
* ***9.9.9.10***

### Google DNS <a name="google-dns"/></a>
[Google DNS](https://developers.google.com/speed/public-dns/) claims to speed up browsing and offer
better security, however nothing is called out around privacy as they like to monitor heavily.

* ***8.8.8.8***
* ***8.8.4.4***

### DNSSEC Validation Failures <a name="dnssec-validation-failures"/></a>
After updating to the latest bits 5.2.11 kernel for reference I started getting DNS failures:

```bash
# Check the status of systemd resolved
$ sudo systemctl status systemd-resolved
...
Sep 02 20:04:08 main4 systemd-resolved[668]: DNSSEC validation failed for question io IN DS: signature-expired
...
```

Apparently DNSSEC is known to fail and the work around is to turn it off.
https://wiki.archlinux.org/index.php/Systemd-resolved#DNSSEC

```bash
# /etc/systemd/resolved.conf.d/dnssec.conf
# [Resolve]
# DNSSEC=false

# Then restart the service
$ sudo systemctl restart systemd-resolved
```


# Network Interfaces <a name="network-interfaces"/></a>

## Bind to NIC <a name="bind-to-nic"/></a>
Many Linux apps will by default bind to all available network interfaces. This is a nightmare for
end users that want control of which nics are used. To get around this many techniques have been
developed to replace code at runtime using LD_PRELOAD shims to inform the dynamic linker to first
load all libs into the process that you want then add some more.

```bash
# Compile code
wget http://daniel-lange.com/software/bind.c -O bindip.c
gcc -nostartfiles -fpic -shared bindip.c -o bindip.so -ldl -D_GNU_SOURCE

# Install binary
strip bindip.so
sudo cp bindip.so /usr/lib/

# Check existing binding of teamviewer
netstat -nl | grep 5938
tcp        0      0 0.0.0.0:5938            0.0.0.0:*               LISTEN     

# Edit teamviewer unit and add teh new start up line below
sudo systemctl stop teamviewerd
sudo sed -i -e 's|^\(PIDFile=.*\)|\1\nEnvironment=BIND_ADDR=10.33.234.133 LD_PRELOAD=/usr/lib/bindip.so|' /usr/lib/systemd/system/teamviewerd.service
sudo systemctl daemon-reload
sudo systemctl start teamviewerd

# Check resulting binding
netstat -nl | grep 5938
tcp        0      0 10.33.234.133:5938      0.0.0.0:*               LISTEN     
```

## Configure Multiple IPs <a name="configure-multiple-ips"/></a>
In Linux its easy to add more than one ip address to a given NIC. But if your service binds to all
NICs then your not going to get an open port, use [Bind to NIC](#bind-to-nic) to limit the service
to a specific IP address then create another to forward ports to.

```bash
# Add an address to your NIC
sudo tee -a /etc/systemd/network/20-dhcp.network <<EOL

[Address]
Address=192.168.0.1/24
[Address]
Address=192.168.0.2/24
EOL

# Restart networking for it to take affect
sudo systemctl restart systemd-networkd

# Check new IPs exist
ip a
# inet 192.168.0.1/24 brd 192.168.0.255 scope global enp0s25
# inet 192.168.0.2/24 brd 192.168.0.255 scope global enp0s25
```

# Network Manager <a name="network-managerr"/></a>
I've switched over to using NetworkManager with cyberlinux due to the user friendlyness of the 
system and its native support for wireguard.

[NetworkManager](https://wiki.archlinux.org/title/NetworkManager) Network Manager is a frontend for 
backend providers. Network Manager provides a nice system tray icon with UI wizards on par with OSX 
that then automate the configuration of backend providers like `systemd-networkd`, `wpa_supplicant`, 
and `openvpn`. NetworkManager has native support for `WireGuard` all it needs is the `wireguard` 
kernel module. The point of NetworkManager is to make networking configuration and setup as painless 
and automatic as possible. It should just work.

## Install <a name="install-network-manager"/></a>
The following installation provides the systemd service `NetworkManager` and 
`NetworkManager-wait-online` the system tray applet `nm-applet` the graphical editor 
`nm-connection-editor` support for WiFi devices which NetworkManager default to use `wpa_supplicant` 
and openvpn integration.

1. Install Network Manager
   ```bash
   $ sudo pacman -S network-manager-applet networkmanager-openvpn wpa_supplicant
   ```
2. Disable `systemd-networkd`
   ```bash
   $ sudo systemctl disable systemd-networkd
   $ sudo systemctl disable systemd-networkd-wait-online
   $ sudo systemctl stop systemd-networkd.socket systemd-networkd
   ```
3. Enable and start Network Manager
   ```bash
   $ sudo systemctl enable NetworkManager
   ```

## Configure <a name="configure-network-manager"/></a>
Configuration load order with later files overriding ealier ones:
1. `/usr/lib/NetworkManager/conf.d`
2. `/run/NetworkManager/conf.d` per boot configuration for one time changes
3. `/etc/NetworkManager.conf`
4. `/etc/NetworkManager/conf.d`
5. `/var/lib/NetworkManager/NetworkManager-intern.conf` not user modifiable but can shadow things

By default if no other connection profiles exist in `/etc/NetworkManager/system-connections` then 
NetworkManager will create an in-memory DHCP connection called `Wired connection 1`. If you have a 
pre-configured connection though it won't do this.

References:
* [Network Manager Settings](https://developer-old.gnome.org/NetworkManager/0.9/ref-settings.html)
* [NetworkManager.conf](https://developer-old.gnome.org/NetworkManager/stable/NetworkManager.conf.html)
* [nmcli examples](https://developer-old.gnome.org/NetworkManager/stable/nmcli-examples.html)
* `man nm-settings`
* `man nmcli`

**See NetworkManager's current settings:**
```bash
$ sudo NetworkManager --print-config
```

### Connection Property Defaults <a name="connection-property-defaults"/></a>
A number of connection properties can have defaults set that will only be used if the connection is 
configured to explicitely use the defaults on a per property basis. This might be a good place to put 
`TCP Slow Start` speedups etc...

### Keyfile Configs <a name="keyfile-configs"/></a>
NetworkManager will read `/etc/NetworkManager/system-connections` for any manually configured 
connections via its `keyfile` plugin which is always enabled. Connection files need to be owned by 
`root` and set to `0600` permissions or they won't be displayed in the list.

keyfile aliases to keep in mind:
* `802-3-ethernet` = `ethernet`
* `802-11-wireless` = `wifi`
* `802-11-wireless-security` = `wifi-security`

**Connection priority**:  
We create the `static` connection profile with a higher connection priority than the DHCP connection 
profile such that it will get tried first if it exists, but we can easily fall back on DHCP by simply 
manually setting it to the active connection profile. To test this you can bring down the connections 
with `nmcli con down "Wired dhcp"` and then `sudo systemctl restart NetworkManager` and 
NetworkManager will restart see the priorities and load the correct one

**Configure DHCP connection:**
```bash
$ sudo cat <<EOF > /etc/NetworkManager/system-connections/dhcp
[connection]
id=Wired dhcp
uuid=$(uuidgen)
type=ethernet
autoconnect-priority=0

[ipv4]
method=auto

[ipv6]
method=disabled
EOF
$ sudo chmod 0600 /etc/NetworkManager/system-connections/dhcp
```

**Configure Static connection:**
```bash
$ sudo cat <<EOF > /etc/NetworkManager/system-connections/static
[connection]
id=Wired static
uuid=$(uuidgen)
type=ethernet
autoconnect-priority=1

[ipv4]
method=manual
address=192.168.1.15/24
gateway=192.162.1.1
dns=127.0.0.53

[ipv6]
method=disabled
EOF
$ sudo chmod 0600 /etc/NetworkManager/system-connections/static
```

**Reload connections from disk:**
```bash
$ sudo nmcli con reload
```
Note: if your new connecdtions don't show up check their permission bits are correct `0600`

**Switch to static connection:**
```bash
$ sudo nmcli con up "Wire static"
```

**Switch to dhcp connection:**
```bash
$ sudo nmcli con up "Wire dhcp"
```

## Network Manager and resolved <a name="network-manager-and-resolved"/></a>
NetworkManager will use `systemd-resolved` automatically as its DNS resolver and cache. You just need 
to ensure that `/etc/resolv.conf` is a symlink to `/run/systemd/resolve/stub-resolv.conf` or you can 
explicitely enable it via editing `/etc/NetworkManager/conf.d/dns.conf` and adding:
```
[main]
dns=systemd-resolved
```

Then reload the configuration with: `sudo nmcli general reload`

# Remoting <a name="remoting"/></a>

## Barrier <a name="barrier"/></a>
Barrier allows you to share a keyboard and mouse between machines (e.g. desktop and laptop). It is a 
fork of the `Synergy 1.9` codebase and the go forward open source solution.

### Install Barrier <a name="install-barrier"/></a>
```bash
$ sudo pacman -S barrier
```

### Configure Barrier Server <a name="configure-barrier-server"/></a>
Note: debugging in the forground can be done with `barriers -f --enable-crypto`

1. From your workstation launch ***Barrier*** from the ***Network*** menu
2. Work through the wizard
3. Select ***Server (share this computer's mouse and keyboard)*** and click ***Finish***
4. Select ***Configure interactively*** and then click ***Configure Server...***
5. Drag a new monitor from top right down to be to the right of ***desktop***
6. Double click the new monitor and name it ***laptop*** and click ***OK***
   Note: the name used here must match the 'Client name' used in the Client section  
7. Navigate to ***File >Save configuration as...*** and save ***barrier.conf*** in your home dir  
8. Now move it to etc: `sudo mv ~/barrier.conf /etc`

### Configure systemd unit <a name="configure-systemd-unit-barrier"/></a>
Barrier needs to attach to your user's X session which means it needs to run as your user. 
cyberlinux provides `/usr/lib/systemd/user/barriers.service` which when run with 
`systemctl --user enable barriers` will create the link `~/.config/systemd/user/default.target.wants/barriers.service`  
1. Enable barriers: `systemctl --user enable barriers`  
2. Start barriers: `systemctl --user start barriers`  

### Configure Barrier Client <a name="configure-barrier-client"/></a>
1. Launch: `barrier`
2. Click ***Next*** to accept ***English*** as the default language
3. Select ***Client (use another computer's mouse and keyboard)*** then ***Finish***
4. Uncheck ***Auto config***
5. Enter server hostname e.g. ***192.168.1.4***
6. Click ***Start***
7. Navigate to ***Edit >Settings*** and check ***Hide on startup*** then ***OK***
8. Click ***File >Save configuration as...*** and save as ***~/.config/barrier.conf***
9. Create autostart for client: `cp /usr/share/applications/barrier.desktop ~/.config/autostart`

## Teamviewer <a name="teamviewer"/></a>
Typically I configure TV to only be accessible from my LAN and tunnel in.

1. Install Teamviewer
  ```bash
  sudo pacman -S teamviewer
  sudo systemctl enable teamviewerd
  sudo systemctl start teamviewerd
  ```
2. Autostart Teamviewer
  ```bash
  cp /usr/share/applications/teamviewer.desktop ~/.config/autostart
  ```
3. Configure Teamviewer  
  a. Start teamviewer: `teamviewer`  
  b. Click ***Accept License Agreement***  
  c. Navigate to ***Extras >Options***  
  d. Click ***General*** tab on left  
  e. Set ***Your Display Name***  
  f. Check the box ***Start Teamviwer with system***  
  g. Set drop down ***Incoming LAN connections*** to ***accept exclusively***  
  h. Click ***Security*** tab   
  i. Set ***Password*** and ***Confirm Password***  
  j. Leave ***Start Teamviewer with Windows*** checked and click ***OK*** then ***OK***  
  k. Click ***Advanced*** tab on left  
  l. Disable log files  
  m. Check ***Disable TeamViewer shutdown***  
  n. Click ***OK***  

## Zoom <a name="zoom"/></a>
Seems to be a pretty good quality app.  I simply installed it and selected my plantronics headset
and audio worked great.  My laptop webcam also worked without doing anything.

**Install Manually**
```bash
$ yaourt -G zoom; cd zoom
$ makepkg -s
$ sudo pacman -U zoom-2.4.121350.0816-1-x86_64.pkg.tar.xz
```

**Install from cyberlinux-repo**
```bash
$ sudo tee -a /etc/pacman.conf <<EOL
[cyberlinux]
SigLevel = Optional TrustAll
Server = https://phR0ze.github.io/cyberlinux-repo/$repo/$arch
EOL
$ sudo pacman -Sy zoom
```

# SSH <a name="ssh"/></a>

## Port Forwarding <a name="ssh-port-forwarding"/></a>
Securely forwarding ports via ssh is simple just hard to remember.

```bash
# Forward local host:port to remote host:port using the ssh connection
# e.g. forwards local 192.168.0.1:5938 to remote 192.168.1.10:5938 via user@access-point.com
# 192.168.1.10 in this case is a host accesible from access-point.com

# ssh -L local_host:local_port:remote_host:remote_port user@access-point.com
ssh -L 192.168.0.1:5938:192.168.1.10:5938 -p 23 user@access-point.com

# Forward 5938 from access-point.com directly
ssh -L 192.168.0.1:5938:127.0.0.1:5938 -p 23 user@access-point.com

# Check resulting ports
netstat -nl | grep 5938
tcp        0      0 192.168.0.1:5938        0.0.0.0:*               LISTEN     
tcp        0      0 10.33.234.133:5938      0.0.0.0:*               LISTEN     
```

# sshuttle <a name="sshuttle"/></a>
https://github.com/sshuttle/sshuttle

# systemd-networkd <a name="systemd-networkd"/></a>
`systemd-networkd` is a bare bones, light and simple networking configuration. In conjunction with 
`wpa_supplicant` and `WPA_UI` I've got by just fine. However it does lack some of the elegance 
heavier weight solutions like Network Manager provide.

## Install systemd-networkd <a name="install-systemd-networkd"/></a>
1. Disable `NetworkManager`
   ```bash
   $ sudo systemctl disable NetworkManager
   $ sudo systemctl disable NetworkManager-wait-online
   ```
2. Disable `nm-applet`
   ```bash
   $ sudo rm /etc/xdg/autostart/nm-applet.desktop
   ```
3. Enable `systemd-networkd`
   ```bash
   $ sudo systemctl enable systemd-networkd
   $ sudo systemctl enable systemd-networkd-wait-online
   ```

## DHCP Networking <a name="dhcp-networking-systemd-networkd"/></a>
```bash
# Create config file
sudo tee -a /etc/systemd/network/10-static.network <<EOL
[Match]
Name=en* eth*

[Network]
DHCP=ipv4
IPForward=kernel

[DHCP]
UseDomains=true
EOL

# Configure DNS
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

# Enable/start resolved
sudo systemctl enable systemd-networkd systemd-resolved
sudo systemctl start systemd-networkd systemd-resolved

# Restart networking
sudo systemctl restart systemd-networkd
```

## Static Networking <a name="static-networking-systemd-networkd"/></a>
```bash
# Create config file
sudo tee -a /etc/systemd/network/10-static.network <<EOL
[Match]
Name=en* eth*

[Network]
Address=192.168.1.6/24
Gateway=192.168.1.1
DNS=1.1.1.1
DNS=1.0.0.1
IPForward=kernel
EOL

# Restart networking
sudo systemctl restart systemd-networkd
```

## Wifi Networking <a name="wifi-networking-systemd-networkd"/></a>
1. Ensure kernel driver is accurate:
  ```bash
  inxi -N
  # Network:   Card-1: Intel Ethernet Connection I217-LM driver: e1000e 
  #            Card-2: Intel Centrino Advanced-N 6235 driver: iwlwifi 
  ```
2. Rename wifi id to something predictable:
  ```bash
  sudo tee /etc/systemd/network/10-wlo1.link <<EOL
  [Match]
  OriginalName=wl*

  [Link]
  Name=wlo1
  EOL
  sudo reboot
  ```

3. Ensure ***systemd-networkd*** has been configured:
  ```bash
  sudo tee /etc/systemd/network/30-wireless.network <<EOL
  [Match]
  Name=wl*

  [Network]
  DHCP=ipv4
  IPForward=kernel

  [DHCP]
  RouteMetric=20
  UseDomains=true
  EOL
  sudo systemctl daemon-reload
  sudo systemctl restart systemd-networkd
  ```
4. Create minimal ***wpa_supplicant*** config:
  ```bash
  sudo pacman -S wpa_supplicant wpa_gui
  sudo tee /etc/wpa_supplicant/wpa_supplicant-wlo1.conf <<EOL
  ctrl_interface=/run/wpa_supplicant
  ctrl_interface_group=wheel
  update_config=1
  p2p_disabled=1
  EOL
  sudo systemctl daemon-reload
  sudo systemctl enable wpa_supplicant@wlo1
  sudo systemctl start wpa_supplicant@wlo1
  sudo systemctl status wpa_supplicant@wlo1
  ```
4. Configure Wifi Connection:
   a. Launch the gui: `sudo wpa_gui`  
   b. Click `Scan >Scan`  
   c. Double click the target network   
   d. Choose `CCMP` as the Encryption method for `AES` endpoints  
   e. Enter the `PSK` and click `Add`  
   f. Click `Close` and you should see it is already `Completed` i.e. connected  

# NFS Shares <a name="nfs-shares"/></a>
https://wiki.archlinux.org/index.php/NFS

## NFS Client Config <a name="nfs-client-config"/></a>
* ***nfs*** – calls out the type of technology being used
* ***auto*** – maps the share immediately rather than waiting until it is accessed
* ***noacl*** – turns off all ACL processing, if your not woried about security i.e. home network this is find to turn off
* ***noatime*** – disables NFS from updating the inodes access time, it can be safely ignored to speed up performance a bit
* ***nodiratime*** – same as noatime but for directories
* ***rsize and wsize*** - bytes read from server, default: 1024, larger values e.g. 8192 improve throughput
* ***timeo=14*** – time in tenths of a second to wait before resending a transmission after an RPC timeout, default: 600
* ***_netdev*** – tells systemd to wait until the network is up before tyring to mount the share

```bash
# Check exported list on client side
$ showmount -e 192.168.1.3

# Create local mount points
$ sudo mkdir -p /mnt/{Cache,Documents,Educational,Family,Install,Kids,Movies,Pictures,TV}

# Set local mount point ownership to your user
$ sudo chown -R <user-name>: /mnt/{Cache,Documents,Educational,Family,Install,Movies,Pictures,TV}

# Optionally manually mount/umount remote share to test it out
$ sudo mount 192.168.1.2:/srv/nfs/Movies /mnt/Movies
$ sudo umount /mnt/Movies

# Setup automount for shares
sudo tee -a /etc/fstab <<EOL
192.168.1.2:/srv/nfs/Cache /mnt/Cache nfs auto,noacl,noatime,nodiratime,rsize=8192,wsize=8192,timeo=15,_netdev 0 0
192.168.1.2:/srv/nfs/Documents /mnt/Documents nfs auto,noacl,noatime,nodiratime,rsize=8192,wsize=8192,timeo=15,_netdev 0 0
192.168.1.2:/srv/nfs/Educational /mnt/Educational nfs auto,noacl,noatime,nodiratime,rsize=8192,wsize=8192,timeo=15,_netdev 0 0
192.168.1.2:/srv/nfs/Family /mnt/Family nfs auto,noacl,noatime,nodiratime,rsize=8192,wsize=8192,timeo=15,_netdev 0 0
192.168.1.2:/srv/nfs/Install /mnt/Install nfs auto,noacl,noatime,nodiratime,rsize=8192,wsize=8192,timeo=15,_netdev 0 0
192.168.1.2:/srv/nfs/Movies /mnt/Movies nfs auto,noacl,noatime,nodiratime,rsize=8192,wsize=8192,timeo=15,_netdev 0 0
192.168.1.2:/srv/nfs/Pictures /mnt/Pictures nfs auto,noacl,noatime,nodiratime,rsize=8192,wsize=8192,timeo=15,_netdev 0 0
192.168.1.2:/srv/nfs/TV /mnt/TV nfs auto,noacl,noatime,nodiratime,rsize=8192,wsize=8192,timeo=15,_netdev 0 0
EOL
sudo mount -a
```

## NFS Server Config <a name="nfs-server-config"/></a>
Kodi recommends the `(rw,all_squash,insecure)` for the export options. In my experience the nfs root
was also required `/srv/nfs             192.168.1.0/24(rw,fsid=0,no_subtree_check)` and although the
linux nfs client worked fine without it, Kodi wouldn't work until it was added.

* ***.0/24*** - suffix allows all devices on the network to be able to see the share
* ***rw*** - allow read write access to the NFs share
* ***all_squash*** - will map all UIDs and GIDs to the anonymous user
* ***no_all_squash*** - (default) will allow users to be detected
* ***insecure*** - allow the use of a client connecting with a port number above `1024`
* ***no_subtree_check*** - (default) but will warn if not called out
* ***root_squash*** - don't allow remote root user to have root priviledges on this share
* ***no_root_squash*** - allows remote root user's to have root priviledges on this share
* ***sync*** - (default) reply to requests only after changes have been written to disk
* ***async*** - reply to requests before changes are written to disk, faster but dangerous

Setup nfs shares:
```bash
# Create target shared directories
$ sudo mkdir -p /srv/nfs/{Cache,Documents,Educational,Family,Install,Movies,Pictures,TV}

# Add shares to exports file
$ sudo tee -a /etc/exports <<EOL
/srv/nfs             192.168.1.0/24(rw,fsid=0,no_subtree_check)
/srv/nfs/Cache       192.168.1.0/24(rw,no_root_squash,insecure,no_subtree_check)
/srv/nfs/Documents   192.168.1.0/24(rw,root_squash,insecure,no_subtree_check)
/srv/nfs/Educational 192.168.1.0/24(ro,all_squash,insecure,no_subtree_check)
/srv/nfs/Family      192.168.1.0/24(ro,all_squash,insecure,no_subtree_check)
/srv/nfs/Install     192.168.1.0/24(ro,all_squash,insecure,no_subtree_check)
/srv/nfs/Movies      192.168.1.0/24(ro,all_squash,insecure,no_subtree_check)
/srv/nfs/Pictures    192.168.1.0/24(ro,all_squash,insecure,no_subtree_check)
/srv/nfs/TV          192.168.1.0/24(ro,all_squash,insecure,no_subtree_check)
EOL

# Optionally manually bind mount directories as a test
$ sudo mount --bind /mnt/storage/Movies /srv/nfs/Movies

# Auto Bind mount directories
$ sudo tee -a /etc/fstab <<EOL
/mnt/storage/Cache /srv/nfs/Cache none bind 0 0
/mnt/storage/Documents /srv/nfs/Documents none bind 0 0
/mnt/storage/Educational /srv/nfs/Educational none bind 0 0
/mnt/storage/Family /srv/nfs/Family none bind 0 0
/mnt/storage/Install /srv/nfs/Install none bind 0 0
/mnt/storage/Movies /srv/nfs/Movies none bind 0 0
/mnt/storage/Pictures /srv/nfs/Pictures none bind 0 0
/mnt/storage/TV /srv/nfs/TV none bind 0 0
EOL
$ sudo mount -a

# Ensure nfs-server is started
$ sudo systemctl start nfs-server

# Re-export your shares to pick up changes
$ sudo exportfs -r

# Check what is currently being served
$ sudo exportfs -v
```

## systemd-networkd-wait-online timing out <a name="systemd-networkd-wait-online-timing-out"/></a>
While trouble shooting a NFS share failing to mount I ran into this interesting tid bit of
information. Turns out that `systemd-networkd-wait-online` by default will wait for all network
interfaces to be ready. This means if you have a system with multiple nics and only use one the
others will be in a perpetual `configuring` state which cause `systemd-networkd-wait-online` to
always time out which is super annoying. A better default would be to have it to use the `--any` flag
which will cause it to succeed if any nics are online.

```bash
# Find name of mount unit
$ sudo systemctl | grep Cache
mnt-Cache.mount

# List out the dependencies and found `systemd-networkd-wait-online.service` was in red
$ sudo systemctl list-dependencies mnt-Cache.mount
mnt-Cache.mount
● ├─system.slice
● └─network-online.target
●   └─systemd-networkd-wait-online.service

# Checking the status of `system-networkd-wait-online`
$ sudo systemctl status systemd-networkd-wait-online.service
...
     Active: failed (Result: exit-code) since Sun 2020-12-27 16:36:39 MST; 9min ago
       Docs: man:systemd-networkd-wait-online.service(8)
   Main PID: 468 (code=exited, status=1/FAILURE)
...

# Network status indicated it timed out waiting for a network interface that was not yet configured
# https://github.com/systemd/systemd/issues/2713
$ sudo networkctl status
...
Dec 27 16:36:39 main4 systemd[1]: Failed to start Wait for Network to be Configured.

# Checkint my interfaces I have one in a `configuring` state i.e. not ready
$ sudo networkctl -a
IDX LINK    TYPE     OPERATIONAL SETUP      
  1 lo      loopback carrier     unmanaged  
  2 eno1    ether    no-carrier  configuring
  3 enp1s0  ether    routable    configured 

# Turns out that by default `systemd-networkd-wait-online` will wait for `all` network interfaces
# to be line even if they are not currently being used. So we need to modify its configuration
# so that it only waits for at least 1 to be ready by default.
# https://askubuntu.com/questions/1217252/boot-process-hangs-at-systemd-networkd-wait-online

# Create this override file to tell it to only wait for 1 interface
$ sudo mkdir -p /etc/systemd/system/systemd-networkd-wait-online.service.d
$ sudo tee -a /etc/systemd/system/systemd-networkd-wait-online.service.d/override.conf <<EOL
[Service]
# To replace values here we need to first clear out the value
ExecStart=
# Then set it to what we want, else it will be addative
ExecStart=/usr/lib/systemd/systemd-networkd-wait-online --any
EOL

# Restarting the service completes immediately meaning we fixed it
$ sudo systemctl restart systemd-networkd-wait-online
```

# VPN <a name="vpn"/></a>

## OpenConnect <a name="openconnect"/></a>
https://wiki.archlinux.org/index.php/OpenConnect  
OpenConnect is a client for Cisco's AnyConnect SSL VPN and Pulse Secure's Pulse Connect Secure.

**Note:** I kept wanting to pass in all the fields I could. It works better to use the minimal args
and OpenConnect will then prompt for information it needs.

```bash
# Install OpenConnect
$ sudo pacman -S openconnect vpnc

# Connect to AnyConnect VPN
$ sudo openconnect --user=<USER-NAME> --authgroup=<AUTH-GROUP> <VPN GATEWAY NAME/IP>
...
Please enter your username and password.
Password:
# When prompted for `Password:` paste in your ldap password
Password:
# When prompted again for `Password:` u may or may not have a second
Verification code:
Response:
# When prompted for `Response:` paste in authy code
Connect Banner:
Welcome to Example VPN!

# Route shows correct routing?
$ route

# Check correct dns
$ systemd-resolved --status
```

## OpenVPN <a name="openvpn"/></a>
Many VPN services are based on OpenVPN. In this section I'll be working through common configuration
options. OpenVPN client configuration files are stored in `/etc/openvpn/client` usually with the `.ovpn`
extension.

## Split DNS Resolution <a name="split-dns-resolution"/></a>
Split DNS resolution allows for using the VPN's DNS name servers for resolution for all things over
the VPN and your normal DNS name servers for everything else.
[update-systemd-resolved](https://github.com/jonathanio/update-systemd-resolved) is a helper script
that reads from the `dhcp-option` in the server or client config then applies them dynamically to
`systemd` via the `dbus`.

1. Install from the cyberlinux repo:
   ```bash
   $ sudo pacman -S openvpn-update-systemd-resolved
   ```
2. Install OpenVPN client configuration file:
   ```bash
   $ sudo mv <client>.ovpn /etc/openvpn/client
   ```
3. Revoke read permissions on the client config to keep secrets secure:
   ```bash
   $ sudo chmod og-r /etc/openvpn/client/<client>.ovpn
   ```
4. Establish the VPN connection with Split DNS Resolution:
   ```bash
   $ sudo openvpn --config /etc/openvpn/client/<client>.ovpn --setenv PATH \
       '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' \
       --script-security 2 --up /etc/openvpn/scripts/update-systemd-resolved \
       --down /etc/openvpn/scripts/update-systemd-resolved --down-pre
   ```
5. Check that the Split DNS was configured correctly:
   ```bash
   # Look for new nameserver entries for the vpn
   $ sudo resolvectl status
   Link 18 (tun0)
   Current DNS Server: <NAMESERVER 1>
   ```

### systemd-resolved and vpn dns
`systemd-resolved` first checks for system overrides at `/etc/systemd/resolved.conf` then for network
configuration at `/etc/systemd/network/*.network`, then vpn dns configuration and finally falls back
on the fallback configuration in `/etc/systemd/resolved.conf`. I've found the most reliable way to
get vpn dns to work correctly is to not set anything except the fallback configuration so that dns is
configured by openconnect and when not on the vpn dns is configured by the fallback.

### systemd-resolved nsswitch configuration
cyberlinux just worked out of the box but Ubuntu, although using `systemd-resolved` doesn't have
`nsswitch` setup correctly.

You can verify if it is working by checking the DNS configured with `systemd-resolved --status`. If
that returns the VPN's dns then your good if not check below as I had to on Ubuntu

The problem is that `/etc/nsswitch.conf` is not configured to use `systemd-resolved` even
though Ubuntu Pop has systemd-resolved running.  To fix this you need to add
`resolve` before `[NOTFOUND=return]` on the `hosts` line, no restarts are necessary

Example of fixed:
```bash
hosts: files mdns4_minimal resolve [NOTFOUND=return] dns myhostname
```

# WireGuard <a name="wireguard"/></a>
[WireGuard](https://www.wireguard.com/) is a secure networking tunnel. It can be used as a VPN, for 
connecting datacenters together across the internet any place where you need to join two networks 
together. It was initially released for the Linux kernel, it is now cross-platform (Windows, macOS, 
BSD, iOS, Android) and is widely deployable. WireGuard aims to be as easy to configure and deploy 
as SSH. A VPN connection is made simply by exchanging very simple public keys exactly like exchanging 
SSH keys and all the rest is transparently handled by WireGuard.

WireGuard uses modern ciphers like the `Noise protocol framework`, `Curve25519`, `ChaCha20`, 
`Poly1305`, `BLAKE2`, `SipHash24`, `HKDF`. It works by adding a network interface like `eth0` or 
`wlan0` called `wg0`. This network interface can then be configured normally using `ip` with routes 
for it added and removed via `route` or `ip-route` and so on using all the normal networking 
utilities.

References:
* [Arch Linux WireGuard](https://wiki.archlinux.org/title/WireGuard)

Features:
* Faster, lighter and better than OpenVPN and IPsec and other VPN tech made in the 90s.
* Can't scan for it on the internet, its undetectable unless you know where it is
* Has a very small code base that can fit into the kernel

## WireGuard Client <a name="wireguard-client"/></a>

### Install WireGuard <a name="install-wireguard"/></a>
```bash
$ sudo pacman -S wireguard-tools
```

### Generate private/public key pair <a name="setup-wireguard"/></a>

### Configure all traffic tunnel <a name="configure-all-traffic-tunnel"/></a>
```
cat /etc/wireguard/wg0.conf
[Interface]
PrivateKey = `PRIVATEKEY`
Address = `IPV4FROMVPNPROVIDER`,`IPV6FROMVPNPROVIDER`
DNS = `VPNDNS4`,`VPNDNS6`
PostUp = ip route add `192.168.1.0/24 via 192.168.1.1`;
PreDown = ip route delete `192.168.1.0/24`;

[Peer]
PublicKey = `PUBLICKEY`
AllowedIPs = `0.0.0.0/0`,`::0/0`
Endpoint = `PUBLICVPNSERVERIP`:`PORT`
PersistentKeepalive = 25
```

### Starting WireGuard <a name="starting-wireguard"/></a>
```bash
$ sudo systemctl enable wg-quick@wg0
$ sudo systemctl start wg-quick@wg0
```

## WireGuard Server <a name="wireguard-server"/></a>
1. Enable kernel ipv4 forwarding
   ```bash
   $ echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.d/10-ipv4-forwarding.conf
   ```
2. 
