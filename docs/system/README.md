system
====================================================================================================
<img align="left" width="48" height="48" src="../../art/logo_256x256.png">
Documentation for various system technologies
<br><br>

### Quick links
* [.. up dir](..)
* [Distros](distros)
* [Flatpak](flatpak)
* [Powerline](#powerline)
  * [Installing Powerling](#installing-powerline)
  * [Powerline GitStatus](#powerline-git-status)
  * [Troubleshooting Powerline](#troubleshooting-powerline)
* [Systemd](#systemd)
  * [Systemd Status](#systemd-status)
  * [Systemd Boot Performance](#systemd-boot-performance)
    * [See How long boot takes](#see-how-long-boot-takes)
    * [Rank services by startup time](#rank-services-by-startup-time)
    * [Remove lvm2 service](#remove-lvm2-service)
  * [Systemd Debug Shell](#systemd-debug-shell)
  * [Systemd Timers](#systemd-timers)
    * [Shutdown Timer](#shutdown-timer)
* [System Update](#system-update)
* [Thunar](#thunar)
  * [Thunar webp thumbnails](#thunar-webp-thumbnails)
* [Wine](wine)

# Powerline
https://powerline.readthedocs.io/en/latest/usage/shell-prompts.html#bash-prompt

## Installing Powerline
1. Install powerline scripts
   ```bash
   $ sudo pacman -S powerline
   ```
2. Add the bash sourcing to `~/.bashrc`
   ```bash
   if [[ $(tty) != *"tty"* ]] && [ -f /usr/bin/powerline ]; then
     powerline-daemon -q
     POWERLINE_BASH_CONTINUATION=1
     POWERLINE_BASH_SELECT=1
     . /usr/share/powerline/bindings/bash/powerline.sh
   fi
   ```

## Powerline Git Status
When the version of python rolls the gitstatus libraries are not findable and you get error messages 
like below indicating that the corresponding site-package doesn't exist.
```
2021-12-28 09:30:11,240:ERROR:shell:segment_generator:Failed to import attr gitstatus from module powerline_gitstatus: No module named 'powerline_gitstatus'
Traceback (most recent call last):
  File "/usr/lib/python3.10/site-packages/powerline/__init__.py", line 392, in get_module_attr
```

Solution is to re-build the package:
1. Clone the [cyberlinux-aur](https://github.com/phR0ze/cyberlinux-aur) repo
2. Navigate to `powerline-gitstatus`
3. Edit `PKGBUILD` and increment the `pkgrel` value
4. Run: `makepkg -s`
5. Upgrade: `sudo pacman -U powerline-gitstatus-1.3.1-3-any.pkg.tar.zst`

## Toubleshooting Powerline
Try linting the configuration:
```bash
$ powerline-lint
```

Try killing the daemon then running a command in a shell with powerline already enabled:
1. Kill the daemon
   ```bash
   $ sudo killall powerline-daemon
   ```
2. Run a command and watch the output
   ```bash
   $ ls
   gitstatus.install  PKGBUILD
   2020-12-22 16:02:43,239:ERROR:shell:segment_generator:Failed to import attr gitstatus from module powerline_gitstatus: No module named 'powerline_gitstatus'
   Traceback (most recent call last):
     File "/usr/lib/python3.9/site-packages/powerline/__init__.py", line 392, in get_module_attr
       return getattr(__import__(module, fromlist=(attr,)), attr)
   ModuleNotFoundError: No module named 'powerline_gitstatus'
   2020-12-22 16:02:43,240:ERROR:shell:segment_generator:Failed to generate segment from {'function': 'powerline_gitstatus.gitstatus', 'priority': 50}: Failed to obtain segment function
   Traceback (most recent call last):
     File "/usr/lib/python3.9/site-packages/powerline/segment.py", line 328, in get
       contents, _contents_func, module, function_name, name = get_segment_info(data, segment)
     File "/usr/lib/python3.9/site-packages/powerline/segment.py", line 69, in get_function
       raise ImportError('Failed to obtain segment function')
   ImportError: Failed to obtain segment function
   ```
3. Notice that the `powerline_gitstatus` module is missing for python 3.9
4. To get a clean bash terminal you'll need to disable powerline in `~/.bashrc` then open a new shell

# System Update <a name="system-update"/></a>
1. Update keyring first
   ```bash
   $ sudo pacman -Sy archlinux-keyring

   # Note if your system is so old that it doesn't trust any keys you can
   # copy the keys from a different machine: sudo scp -r /etc/pacman.d
   ```

2. [Update mirrorlist](#update-mirrorlist)

3. Update full system
   ```bash
   $ sudo pacman -Syu
   ```

# Systemd

## Systemd Status

```bash
# By leaving off a specific unit to get status about we see the status of the entire system
$ systemctl status

# List out all running units and their state
$ systemctl
```

## Systemd Boot Performance
https://wiki.archlinux.org/index.php/Improving_performance/Boot_process

### See How long boot takes
```bash
$ systemd-analyze
Startup finished in 4.800s (kernel) + 2min 3.457s (userspace) = 2min 8.258s 
graphical.target reached after 2min 3.457s in userspace
```

### Rank services by startup time
```bash
$ systemd-analyze blame
2min 200ms systemd-networkd-wait-online.service
  2.012s dev-sda3.device
  1.577s systemd-udevd.service
  1.483s systemd-resolved.service
  1.406s man-db.service
  1.277s systemd-journal-flush.service
   981ms docker.service
   823ms systemd-timesyncd.service
   472ms logrotate.service
   455ms systemd-logind.service
   417ms systemd-networkd.service
   374ms systemd-journald.service
   338ms udisks2.service
   305ms polkit.service
   114ms systemd-rfkill.service
    96ms systemd-udev-trigger.service
    71ms teamviewerd.service
    69ms user@1000.service
    51ms org.cups.cupsd.service
    47ms systemd-binfmt.service
    28ms dev-mqueue.mount
    26ms dev-hugepages.mount
    26ms lvm2-monitor.service
    26ms sys-kernel-debug.mount
    25ms systemd-tmpfiles-setup.service
    24ms kmod-static-nodes.service
    24ms systemd-modules-load.service
    23ms systemd-remount-fs.service
    20ms systemd-tmpfiles-setup-dev.service
    19ms systemd-random-seed.service
    15ms systemd-sysctl.service
    15ms tmp.mount
    13ms systemd-tmpfiles-clean.service
    12ms user-runtime-dir@1000.service
    12ms systemd-update-utmp.service
    11ms proc-sys-fs-binfmt_misc.mount
    10ms systemd-user-sessions.service
     9ms systemd-backlight@backlight:acpi_video0.service
     7ms docker.socket
     7ms systemd-backlight@backlight:nv_backlight.service

$ systemd-analyze critical-chain
graphical.target @2min 3.457s
└─multi-user.target @2min 3.457s
  └─docker.service @2min 2.474s +981ms
    └─network-online.target @2min 2.472s
      └─network.target @3.749s
        └─systemd-resolved.service @2.265s +1.483s
          └─systemd-networkd.service @1.845s +417ms
            └─systemd-udevd.service @263ms +1.577s
              └─systemd-tmpfiles-setup-dev.service @240ms +20ms
                └─kmod-static-nodes.service @190ms +24ms
                  └─systemd-journald.socket @189ms
                    └─system.slice @183ms
                      └─-.slice @183ms
```

### Remove lvm2 service
If you're not using the lvm2 service, which has never seemed a useful feature, then disabling it
will clean up your boot slightly especially since it seems to be trying to start and failing for me.
Unfortunately due to actual useful tools depending on it i.e. `libblockdev` which in turn is
depended upon by `gvfs` which I use, it can't be simply removed. Unless I rebuilt `libblockdev` with
the `--without-lvm` flag which I did and made available in the `cyberlinux-repo`.

Remove lvm2 requires a rebuild of `libblockdev`
```bash
$ 
```

Disable
```bash
# List out all failed units
$ systemctl --failed
● lvm2-monitor.service                 loaded failed failed Monitoring of LVM2 mirrors, snapshots etc. using dmeventd or progress polling

# Checking if lvm2 is enabled gives 'static' which means that its a dependency of something else
$ systemctl is-enabled lvm2-monitor
static

# Mask the lvm2-monitor service
$ sudo systemctl mask lvm2-monitor --now
```

## Systemd Debug Shell
```bash
$ sudo systemctl enable debug-shell

# Logout then switch to debug shell with Ctl+F9
$ systemctl status

# See which apps are hanging
```

## Systemd Timers
Timers are `systemd` unit files with a `.timer` suffix and are systemd's replacement for cron. 
`Realtime timers` activate on a calendar event similar to cronjobs. The `OnCalendar=` option is used 
to define them. Transient timer units can be used via `systemd-run` to run a command without having 
the timer and service units.

**List all timers:**
```bash
$ systemctl list-timers --all
```

**Inspect timer:**
```bash
$ systemctl cat <timer>.timer
```

**Start timer:**
```bash
$ sudo systemctl start <timer>.timer
```

### Shutdown Timer
We can create a timer to shutdown the system at a particular time on week days.
Test with `systemd-analyze calendar "Mon..Fri 14:00"`
Note: the timer unit and the service unit must have the same name.

1. Create the timer unit
```bash
sudo tee /usr/lib/systemd/system/shutdown.timer <<EOL
[Unit]
Description=Shutdown on week days

[Timer]
OnCalendar=Mon..Fri 14:00
Persistent=true

[Install]
WantedBy=timers.target
EOL
```

2. Create the service unit
```bash
sudo tee /usr/lib/systemd/system/shutdown.service <<EOL
[Unit]
Description=Shutdown on week days

[Service]
Type=oneshot
ExecStart=/usr/bin/poweroff
EOL
```

3. Reload the systemd daemon, enable and start the timer
```bash
sudo systemctl daemon-reload
sudo systemctl enable shutdown.timer
sudo systemctl start shutdown.timer
```

# Thunar

## Thunar webp thumbnails
* [Preview WebP in Thunar](https://spacebums.co.uk/thunar-webp-thumbnails/)

1. Install prerequisites
   ```bash
   $ sudo pacman -S libwebp tumbler
   ```
2. Create thumbnailer entry at `/usr/share/thumbnailers/webp.thumbnailer`
   ```
   [Thumbnailer Entry]
   Version=1.0
   Encoding=UTF-8
   Type=X-Thumbnailer
   Name=webp Thumbnailer
   MimeType=image/webp;
   Exec=/usr/bin/convert -thumbnail %s %i %o
   ```
3. Create the new mime type at `~/.local/share/mime/packages/webp.xml`
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
       <mime-type type="image/webp">
           <comment>WebP file</comment>
           <icon name="image"/>
           <glob-deleteall/>
           <glob pattern="*.webp"/>
       </mime-type>
   </mime-info>
   ```
4. Run the mime updater
   ```bash
   $ update-mime-database ~/.local/share/mime
   ```
5. Relog

<!-- 
vim: ts=2:sw=2:sts=2
-->
