Virtualization
====================================================================================================
<img align="left" width="48" height="48" src="../../art/logo_256x256.png">
Documenting various virtualization technologies
<br><br>

### Quick links
* [.. up dir](https://github.com/phR0ze/cyberlinux)
* [QEMU](#qemu)
* [ProxMox](#prox-mox)
* [Virtual Box](#virtual-box)
  * [USB Access in VM](#usb-access-in-vm)

# QEMU
Quick EMUlator is a command line virtual machine system. It is fast, portable and has excellent guest 
support. QEMU supports everything and more than other hypervisors.

**References**
* [Archlinux QEMU](https://wiki.archlinux.org/title/QEMU)

## Install QEMU
Install the command line version only

```bash
$ sudo pacman -S qemu-base
```

## Install ISO with QEMU

1. Download a test image
   1. Navigate to [arch linux mirror](http://mirrors.acm.wpi.edu/archlinux/iso/latest/)
   2. Download the latest `iso`

2. Create a new qcow2 drive to install to
   ```bash
   $ qemu-img create -f qcow2 arch1.qcow2 20G
   ```

3. Create a new VM using the new drive and ISO
   ```bash
   $ qemu-system-x86_64 \
       -enable-kvm \
       -m 4G \
       -nic user,model=virtio \
       -drive file=arch1.qcow2,media=disk,if=virtio \
       -cdrom archlinux-2023.09.01-x86_64.iso
   ```

| Parameters                                      | Description
| ----------------------------------------------- | ---------------------------------------------------
| `-enable-kvm`                                   | Enables the KVM subsystem for hardware acceleration
| `-m 2048`                                       | Specifies 2G of RAM 
| `-nic user,model=virtio`                        | Add virtual nic with high speed virtio driver
| `-drive file=alpine.qcow2,media=disk,if=virtio` | Attach your virtual disk to the guest as `/dev/vda`
| `-cdrom alpine-standard-3.8.0-x86_64.iso`       | Attach ISO as cdrom
| `-sdl`                                          | Use standard graphical output window

## Run QEMU VM
```bash
$ qemu-system-x86_64 \
    -enable-kvm \
    -m 2048 \
    -nic user,model=virtio \
    -drive file=arch1.qcow2,media=disk,if=virtio
```

## QEMU Monitor
You can access the monitor console by pressing `Ctrl+Alt+2` and return to the normal window with 
`Ctrl+Alt+1`.

### Connect via TCP
You can expose the monitor over TCP with the runtime argument `-monitor 
tcp:127.0.0.1:<PORT>,server,nowait` then use netcat `nc 127.0.0.1 <PORT>` and send it commands.

## Snapshots in QEMU

### Run in Immutable mode
Running a VM in immutable mode will discard all changes when the VM is powered off just by running 
with the `-snapshot` parameter. However you can still save the state as a snapshot if you run the 
`commit all` from the monitor console.

# ProxMox
ProxMox Virtual Environment is an open source server virtualization management solution based on 
QEMU/KVM and LXC. Users can manage virtual machines, containers, highly available clusters, storage 
and networks via a web interface or CLI.

**References**
* [ProxMox VE linux course](https://www.youtube.com/watch?v=LCjuiIswXGs)

**Features**
* Web UI
* Virtualization platform
* Super low resource overhead
* Manage VMs as well as Containers
* Self contained full solution

Need to research this. Seems like a nice way to manage VMs and containers

# Virtual Box
There are a number of solutions in the Linux world for Virtual Machine creation and managment, but 
I've found for a number of years that Virtual Box is the simplest cross platform way to deal with 
Virtual Machines.

## USB Access in VM
[Accessing host USB devices in guest](https://wiki.archlinux.org/index.php/VirtualBox#Accessing_host_USB_devices_in_guest)
requires that your user be part of the vboxusers group.

```bash
# Check which groups your user is in
$ groups

# Add your use to the vboxusers group
$ sudo usermod -a -G vboxusers <USER>
```

# Virt Manager

## VDA hard disk
Virt Manager seems to create `vda` devices by default rather than `sda` devices.


## Release keyboard capture
Press `Ctrl+Alt`

<!-- 
vim: ts=2:sw=2:sts=2
-->
