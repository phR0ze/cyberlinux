HP Proliant ML330 G6
====================================================================================================
<img align="left" width="48" height="48" src="../../../art/logo_256x256.png">
Documenting the steps I went through to deploy <b><i>cyberlinux</i></b> onto a server machine
<br><br>

### Quick links
* [.. up dir](..)
* [Install cyberlinux](#install-cyberlinux)
* [Configure cyberlinux](#configure-cyberlinux)
  * [General](#general)
  * [Graphics](#graphics)
  * [Teamviewer](#teamviewer)
  * [Storage Drive](#storage-drive)
  * [NFS Shares](#nfs-shares)
  * [qBittorrent](#qbittorrent)
  * [Tiny Media Manager](#tiny-media-manager)
  * [Configure Vopono](#configure-vopono)

# Install cyberlinux <a name="install-cyberlinux"/></a>
1. Boot from the USB:  
   a. Plug in the [Multiboot USB](../../../cyberlinux#create-multiboot-usb)  
   b. Power on the system and wait for the boot into the USB  

3. Install `cyberlinux`:  
   a. Select the desired deployment type e.g. `Install xfce server`  
   b. Complete out the process and unplug the USB  
   c. Reboot your system usually `Ctrl+Alt+Delete` and login  

# Configure cyberlinux <a name="configure-cyberlinux"/></a>

## General <a name="general"/></a>
1. Copy over ssh keys to `~/.ssh`
2. Ensure the ssh keys are only readable by the user `chmod og-rwx -R ~/.ssh`
2. Copy over any wallpaper to `/usr/share/backgrounds`

## Graphics <a name="graphics"/></a>
1. Turn off Xfwm's compositing to improve your remote desktop experience
2. Set the power manager to never `Blank after` your display and set it to `Presentation mode`

## Teamviewer <a name="teamviewer"/></a>
1. Launch Teamviewer from the tray icon
2. Navigate to `Extras >Options`
3. Set `Choose a theme` to `Dark` and hit `Apply`
4. Navigate to `Advanced` and set `Personal password` and hit `OK`

## Storage Drive <a name="storage-drive"/></a>
1. Create mount point for your storage drive
   ```bash
   $ sudo mkdir /mnt/storage
   $ sudo chown USER: /mnt/storage
   ```
2. Discover your storage device id
   ```bash
   $ lsblk
   ```
3. Add your storage device id to your `/etc/fstab`
   ```bash
   $ sudo bash -c 'blkid /dev/sda1 >> /etc/fstab'
   ```
4. Update your fstab to fit the following usage pattern:
   ```
   UUID="ba6619b0-c3a6-493e-92f0-14bf313d15a3" /mnt/storage1 ext4 defaults,noatime 0 0
   ```
5. Mount it manually
   ```bash
   $ sudo mount -a
   ```
6. Finally making a link to your storage drive in your home directory is useful
   ```bash
   $ ln -s /mnt/storage ~/Storage
   ```

## NFS Shares <a name="nfs-shares"/></a>
1. Create bind mount paths as necessary to match your storage drive
   ```bash
   $ sudo mkdir -p /srv/nfs/{Cache,Documents,Movies,TV}
   ```
2. Update your NFS shares to include these paths
   ```bash
   $ sudo tee -a /etc/exports <<EOL
/srv/nfs             192.168.1.0/24(rw,fsid=0,no_subtree_check)
/srv/nfs/Cache       192.168.1.0/24(rw,no_root_squash,insecure,no_subtree_check)
/srv/nfs/Documents   192.168.1.0/24(rw,root_squash,insecure,no_subtree_check)
/srv/nfs/Movies      192.168.1.0/24(ro,all_squash,insecure,no_subtree_check)
/srv/nfs/TV          192.168.1.0/24(ro,all_squash,insecure,no_subtree_check)
EOL
   ```
3. Bind mount the nfs shares to the storage paths
   ```bash
   $ sudo tee -a /etc/fstab <<EOL
/mnt/storage/Cache /srv/nfs/Cache none bind 0 0
/mnt/storage/Documents /srv/nfs/Documents none bind 0 0
/mnt/storage/Movies /srv/nfs/Movies none bind 0 0
/mnt/storage/TV /srv/nfs/TV none bind 0 0
EOL
   ```
4. Update mount points
   ```bash
   $ sudo mount -a
   ```
5. Re-export your NFS shares
   ```bash
   $ sudo exportfs -r
   ```
6. Check that the NFS exported shares are correct
   ```bash
   $ sudo exportfs -v
   ```

## qBittorrent <a name="qbittorrent"/></a>
1. Restore torrent cache
   ```bash
   $ mv ~/Storage/Backup/torrents ~/Downloads
   ```
2. Restore qBittorrent configuration
   ```bash
   $ mkdir -p ~/.local/share/data
   $ cp -a ~/Storage/Backup/.config/qBittorrent ~/.config
   $ cp -a ~/Storage/Backup/.local/share/data/qBittorrent ~/.local/share/data
   ```

## Tiny Media Manager <a name="tiny-media-manager"/></a>
1. Restore tiny media manager data
   ```bash
   $ sudo cp -a ~/Storage/Backup/tiny-media-manager/data /usr/share/tiny-media-manager/data
   ```
2. Restore tiny media manager cache
   ```bash
   $ sudo cp -a ~/Storage/Backup/tiny-media-manager/cache /usr/share/tiny-media-manager/cache
   ```

## Configure Vopono <a name="configure-vopono"/></a>
1. Configure vopono run: `vopono sync PrivateInternetAccess`
2. Choose the `Strong` UDP option
2. Enter your username and password
3. List out available servers with `vopono servers PrivateInternetAccess`
4. Usage to run an application with vopono
   ```bash
   $ vopono exec --provider PrivateInternetAccess --server us_west firefox
   ```

<!-- 
vim: ts=2:sw=2:sts=2
-->
