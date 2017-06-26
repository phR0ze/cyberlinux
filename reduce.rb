#!/usr/bin/env ruby
#MIT License
#Copyright (c) 2017 phR0ze
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

require 'erb'                   # leverage erb for templating
require 'fileutils'             # advanced file utils: FileUtils
require 'mkmf'                  # system utils: find_executable
require 'open-uri'              # easily read HTTP
require 'ostruct'               # OpenStruct
require 'open3'                 # Better system commands
require 'rubygems/package'      # tar
require 'yaml'                  # YAML

require_relative 'lib/erb'      # ERB Handlers for different types
require_relative 'lib/change'   # Programatic file editor
require_relative 'lib/cmds'     # optparse wrapper for commands
require_relative 'lib/sys'      # System helpers

# Gems that should already be installed
begin
  require 'colorize'            # color output: colorize
  require 'filesize'            # human readable file sizes: Filesize
  require 'net/ssh'             # ssh integration: Net::SSH
  require 'net/scp'             # scp integration: Net::SCP
rescue Exception => e
  mod = e.message.split(' ').last.sub('/', '-')
  !puts("Error: install missing module with 'sudo gem install --no-user-install #{mod}'") and exit
end

class Reduce

  def initialize
    @type = OpenStruct.new({
      img: 'img',
      iso: 'iso',
      box: 'box',
      tgz: 'tgz',
      sqfs: 'sqfs'
    })
    @k = OpenStruct.new({
      AUR: 'AUR',
      base: 'base',
      build: 'build',
      changes: 'changes',
      command: 'command',
      cpus: 'cpus',
      conflict: 'conflict',
      container: 'container',
      desc: 'desc',
      docker: 'docker',
      FOREIGN: 'FOREIGN',
      GEM: 'GEM',
      i686: 'i686',
      ignore: 'ignore',
      install: 'install',
      layer: 'layer',
      layers: 'layers',
      machine: 'machine',
      mirrors: 'mirrors',
      multilib: 'multilib',
      off: 'off',
      offline: 'offline',
      packages: 'packages',
      params: 'params',
      pgp_key: 'pgp_key',
      pkg: 'pkg',
      ram: 'ram',
      repo: 'repo',
      repos: 'repos',
      type: 'type',
      vagrant: 'vagrant',
      vars: 'vars',
      vram: 'vram',
      v3d: 'v3d',
      x86_64: 'x86_64',
    })

    @rootpath = File.dirname(File.expand_path(__FILE__))
    @spec_file = File.join(@rootpath, 'spec.yml')
    @spec = YAML.load_file(@spec_file)
    @vars = OpenStruct.new(@spec[@k.vars])
    @user = Process.uid.zero? ? Etc.getpwuid(ENV['SUDO_UID'].to_i).name : ENV['USER']
    @runuser = "runuser #{@user} -c"
    @sudoinv = Process.uid.zero? ? "sudo -Hu #{@user} " : ''

    # Set proxy vars
    @proxyenv = {
      'ftp_proxy' => ENV['ftp_proxy'],
      'http_proxy' => ENV['http_proxy'],
      'https_proxy' => ENV['https_proxy'],
      'no_proxy' => ENV['no_proxy']
    }
    @proxy = ENV['http_proxy']
    @proxy_export = @proxy ? (@proxyenv.map{|k,v| "export #{k}=#{v}"} * ';') + ";" : nil

    # Set paths
    @aurpath = File.join(@rootpath, 'aur')
    @outpath = File.join(@rootpath, 'temp')
    @layerspath = File.join(@rootpath, 'layers')
    @vagrantpath = File.join(@rootpath, 'vagrant')

    @aurcache = File.join(@outpath, 'aur')
    @gemscache = File.join(@outpath, 'gems')
    @workpath = File.join(@outpath, 'work')

    @tmp_dir = File.join(@workpath, 'tmp')
    @isopath = File.join(@workpath, '_iso_')
    @isoimagesdst = File.join(@isopath, @vars.distro.downcase)

    @pacman_conf = File.join(@workpath, 'pacman.conf')
    @pacman_orig_conf = File.join(@layerspath, 'base', 'etc', 'pacman.conf')
    @makepkg_conf = File.join(@workpath, 'makepkg.conf')
    @makepkg_orig_conf = File.join('/usr/share/devtools', "makepkg-#{@vars.arch}.conf")
    @pacman_aur_conf = File.join(@aurcache, 'pacman_aur.conf')

    @vmlinuz_image = File.join(@isoimagesdst, 'vmlinuz')
    @ucode_image = File.join(@isoimagesdst, 'intel-ucode.img')

    @initramfs_src = File.join(@rootpath, 'boot/initramfs')
    @initramfs_work = File.join(@workpath, 'initramfs')
    @initramfs_image = File.join(@isoimagesdst, 'initramfs.img')

    @isolinux_src = File.join(@rootpath, 'boot/isolinux')
    @isolinux_work = File.join(@workpath, 'isolinux')
    @isolinux_dst = File.join(@isopath, 'isolinux')

    @packer_src = File.join(@rootpath, 'packer')
    @packer_work = File.join(@workpath, 'packer')

    @imagepaths = [
      File.join(@outpath, 'images'),
      @isoimagesdst,
      File.expand_path('~').include?('root') ? "/home/#{@user}/Downloads/images" :
        File.join(File.expand_path('~'), 'Downloads', 'images')]

    # Validate spec params
    validate = ->(name, pred){
      !puts("Error: '#{name}' is invalid in '#{@spec_file}'".colorize(:red)) and exit unless pred }
    validate['distro', @vars.distro]
    validate['release', @vars.release]
    validate['arch', [@k.i686, @k.x86_64].include?(@vars.arch)]

    # Configure variables
    @vars.label = "#{@vars.distro.upcase}_#{@vars.release.gsub('.', '')}"
    @spec[@k.layers].select{|x| x[@k.type] == @k.machine}
      .each{|x| @vars["#{x[@k.layer]}_layers"] = getlayers(x[@k.layer]) * ','}
    @spec[@k.layers].each{|x| @vars["#{x[@k.layer]}_src"] = File.join(@layerspath, x[@k.layer])}
    @spec = @spec.erb(@vars)
    @repos = @spec[@k.repos].map{|x| x[@k.repo].upcase} << nil
  end

  # Create directory structure for project
  def create_dir_structure
    uid, gid = Sys.drop_privileges

    puts("Creating directory structure")
    FileUtils.mkdir_p(@workpath)
    FileUtils.mkdir_p(@aurcache)
    FileUtils.mkdir_p(@gemscache)
    FileUtils.mkdir_p(@tmp_dir)
    FileUtils.mkdir_p(@isopath)
    FileUtils.mkdir_p(@isoimagesdst)

    FileUtils.mkdir_p(@initramfs_work)
    FileUtils.mkdir_p(@isolinux_work)
    FileUtils.mkdir_p(@isolinux_dst)

    FileUtils.mkdir_p(@imagepaths.first)
    FileUtils.mkdir_p(@packer_work)
    FileUtils.mkdir_p(@vagrantpath)

    Sys.raise_privileges(uid, gid)
  end

  # Print out distro information
  # Params:
  # +aurpkgs+:: list all aur packages from spec
  # +foreignpkgs+:: list all foreign packages from spec
  # +all+:: list all info
  def info(aurpkgs:nil, foreignpkgs:nil, all:nil)

    if ![aurpkgs, foreignpkgs].any? or all
      # Scrape Arch Linux kernel package
      opts = { ssl_verify_mode: 0, proxy:@proxy }
      page = open("https://www.archlinux.org/packages/core/x86_64/linux", opts).read
      @vars.kernel = page[/<title>(.*?)<\/title>/, 1][/.*linux (.*) \(x86_64\)/, 1]
      @vars.isofile = File.join(@imagepaths.first,
        "#{@vars.distro.downcase}-#{@vars.release}-#{@vars.kernel}-#{@vars.arch}.iso")

      puts("Distro: #{@vars.distro}".colorize(:green))
      puts("Release: #{@vars.release}".colorize(:green))
      puts("Arch: #{@vars.arch}".colorize(:green))
      puts("Kernel: #{@vars.kernel}".colorize(:green))
      puts("Source path: #{@rootpath}".colorize(:green))
      puts("Output path: #{@outpath}".colorize(:green))
      puts("Proxy: #{@proxyenv['http_proxy']}".colorize(:green)) if @proxy
    end

    if aurpkgs or all
        puts("AUR Packages being used:".colorize(:cyan))
        pkgs = getpkgs(nil).values.flatten.map{|x| x[@k.pkg] if x[@k.type] == @k.AUR}.compact.uniq
        pkgs.each{|x| puts("  #{x}")}
    end

    if foreignpkgs or all
        puts("Foreign Packages being used:".colorize(:cyan))
        pkgs = getpkgs(nil).values.flatten.map{|x| x[@k.pkg] if x[@k.type] == @k.FOREIGN}.compact.uniq
        pkgs.each{|x| puts("  #{x}")}
    end
  end

  # List components as directed
  # Params:
  # +boxes+:: list all boxes
  # +isos+:: list all isos
  # +images+:: list all docker images
  # +spec+:: list out the resolved spec
  # +all+:: list all components
  def list(boxes:nil, isos:nil, images:nil, spec:nil, all:nil)
    all = all || ![boxes, isos, images].any?

    # Formatting block for images
    putimages = ->(type, live, name){
      puts("#{name.ljust(85, ' ')}Size:".colorize(:cyan))
      getimages(type, live:live).each{|k,v|
        size = v.to_s.count("a-zA-Z").zero? ? Filesize.from("#{v} B").to_s('MiB') : v
        puts("#{k.ljust(85, ' ')}#{size}")
      }
      puts()
    }

    putimages[@type.box, false, 'Boxes:'] if boxes or all
    putimages[@type.iso, false, 'ISOs:'] if isos or all
    putimages[@type.img, false, 'Machine Boot Images:'] if isos or all
    putimages[@type.sqfs, false, 'Machine Layer Images:'] if isos or all
    putimages[@type.tgz, false, 'Container Layer Images:'] if images or all
    putimages[@type.tgz, true, 'Container Deployed Images:'] if images or all

    # List out the resolved spec
    puts(@spec.to_yaml) if spec
  end

  # Clean components as directed
  # Params:
  # +initramfs+:: clean initramfs component
  # +isolinux+:: clean isolinux component
  # +layers+:: clean given layers
  # +iso+:: clean iso image
  # +vms+:: clean vms
  # +all+:: clean all components
  # +isofull+:: clean iso image including all machine layers
  def clean(initramfs:nil, isolinux:nil, layers:nil, iso:nil, vms:nil, all:nil, isofull:nil)
    !puts("Error: no clean options specified".colorize(:red)) and
      exit unless [initramfs, isolinux, layers, iso, vms, all, isofull].any?
    !puts("Error: must be executed as root".colorize(:red)) and
      exit unless Process.uid.zero?

    # Clean initramfs component
    if initramfs or all or isofull
      puts("Cleaning initamfs...".colorize(:cyan))
      puts("Deleting #{@initramfs_work}".colorize(:red)) if File.exist?(@initramfs_work)
      Sys.rm_rf(@initramfs_work)
      puts("Deleting #{@initramfs_image}".colorize(:red)) if File.exist?(@initramfs_image)
      Sys.rm_rf(@initramfs_image)
    end

    # Clean isolinux component
    if isolinux or layers or all or isofull
      puts("Cleaning isolinux...".colorize(:cyan))
      puts("Deleting #{@isolinux_work}".colorize(:red)) if File.exist?(@isolinux_work)
      Sys.rm_rf(@isolinux_work)
      puts("Deleting #{@isolinux_dst}".colorize(:red)) if File.exist?(@isolinux_dst)
      Sys.rm_rf(@isolinux_dst)

      puts("Deleting #{@ucode_image}".colorize(:red)) if File.exist?(@ucode_image)
      File.delete(@ucode_image) if File.exist?(@ucode_image)
      puts("Deleting #{@vmlinuz_image}".colorize(:red)) if File.exist?(@vmlinuz_image)
      File.delete(@vmlinuz_image) if File.exist?(@vmlinuz_image)
    end

    # Clean given layers
    (layers || (all ? @spec[@k.layers].map{|x| x[@k.layer]} << @k.build : nil) ||
        (isofull ? @spec[@k.layers].select{|x| x[@k.type] == @k.machine}.map{|x| x[@k.layer]} << @k.build : [])).each{|layer|
      puts("Cleaning layer '#{layer}'...".colorize(:cyan))
      path = File.join(@workpath, layer)
      puts("Deleting #{path}".colorize(:red)) if File.exist?(path)
      Sys.rm_rf(path)
      @imagepaths[0..1].each{|path|
        Dir[File.join(path, "#{layer}*")].each{|x|
          puts("Deleting #{x}".colorize(:red))
          File.delete(x)}
      }
      evalimages!(@type.tgz, layer:layer, live:true, force:true)
    }

    # Clean iso image
    if iso or layers or all or isofull
      puts("Cleaning iso...".colorize(:cyan))
      Dir[File.join(@imagepaths.first, '*.iso')].each{|x|
        puts("Deleting #{x}".colorize(:red))
        File.delete(x)
      }
    end

    # Clean iso path
    if isofull
      puts("Cleaning iso path...".colorize(:cyan))
      puts("Deleting #{@isopath}".colorize(:red)) if File.exist?(@isopath)
      Sys.rm_rf(@isopath)
    end

    # Clean all
    if all
      puts("Cleaning all...".colorize(:cyan))
      puts("Deleting #{@workpath}".colorize(:red)) if File.exist?(@workpath)
      Sys.rm_rf(@workpath)
    end

    # Clean vagrant vms that are no longer deployed
    if vms or all
      puts("Cleaning vagrant vms...".colorize(:cyan))
      if File.exist?(@vagrantpath)
        vgout = `#{@sudoinv}vagrant global-status --prune`.split("\n")
        puts(vgout)
        vms = vgout.select{|x| x.include?('virtualbox')}.map{|x| x.split(' ')[1]}
        Dir[File.join(@vagrantpath, '*')].map{|x| File.basename(x)}.each{|vm|
          if !vms.include?(vm)
            path = File.join(@vagrantpath, vm)
            puts("Removing vagrant env. for missing VM #{path}".colorize(:red))
            Sys.rm_rf(path)
          end
        }
      end
    end
  end

  # Build components as directed
  # Params:
  # +initramfs+:: build initramfs component
  # +isolinux+:: build isolinux component
  # +layers+:: build given layers
  # +iso+:: build iso image from whatever machine layers exist
  # +isofull+:: build iso image including all machine layers
  def build(initramfs:nil, isolinux:nil, layers:nil, iso:nil, isofull:nil)
    opts = [initramfs, isolinux, layers, iso, isofull]
    !puts("Error: no build options specified".colorize(:red)) and exit unless opts.any?
    changed = false

    info
    create_dir_structure

    if opts.any?
      !puts("Error: must be executed as root".colorize(:red)) and
        exit unless Process.uid.zero?
      puts("#{'-' * 80}\nBuilding ISO components...\n#{'-' * 80}".colorize(:yellow))

      # Configure arch specific pacman.conf
      FileUtils.cp(@pacman_orig_conf, @pacman_conf)
      FileUtils.cp(@makepkg_orig_conf, @makepkg_conf)
      Fedit.replace(@pacman_conf, /(Architecture = ).*/, "\\1#{@vars.arch}")
    end

    # Build implicated layers
    changed |= build_layers(@k.build) if not (layers || []).include?(@k.build)
    layers = @spec[@k.layers].select{|x| x[@k.type] == @k.machine}.map{|x| x[@k.layer]} if isofull
    layers.each{|layer| changed |= build_layers(layer)} if layers

    # Build early userspace ramdisk for install executed by isolinux
    #changed |= build_initramfs if [initramfs, iso, isofull].any?

#    # Build GFXBoot UI that boots initramfs installer and in turn the real kernel
#    changed |= build_isolinux if [isolinux, iso, isofull].any?
#
#    # Create ISO Hybrid CD/USB bootable image to launch isolinux via xorriso
#    # Note: the eltorito-boot and eltorito-catalog appear to be paths
#    # relative to the construction of the ISO which threw me off for awhile
#    if [iso, isofull].any?
#      puts("#{'-' * 80}\nBuilding ISO Hybrid CD/USB bootable image...\n#{'-' * 80}".colorize(:yellow))
#      if changed or not File.exist?(@vars.isofile)
#        cmd = "xorriso -as mkisofs "
#        cmd += "-iso-level 3 -rock -joliet "
#        cmd += "-max-iso9660-filenames -omit-period "
#        cmd += "-omit-version-number "
#        cmd += "-relaxed-filenames -allow-lowercase "
#        cmd += "-volid \"#{@vars.label}\" "
#        cmd += "-appid \"#{@vars.distro} %s\" " % 'Install/Live CD'
#        cmd += "-publisher \"#{@vars.distro}\" "
#        cmd += "-preparer \"#{@vars.distro}\" "
#        cmd += "-eltorito-boot \"%s\" " % 'isolinux/isolinux.bin'
#        cmd += "-eltorito-catalog \"%s\" " % 'isolinux/boot.cat'
#        cmd += "-no-emul-boot -boot-load-size 4 -boot-info-table "
#        cmd += "-isohybrid-mbr \"#{File.join(@isolinux_dst, 'isohdpfx.bin')}\" "
#        cmd += "-output \"#{@vars.isofile}\" "
#        cmd += "\"#{@isopath}\""
#        if Sys.exec(cmd)
#          puts("Successfully built ISO Hybrid CD/USB bootable image:\n#{@vars.isofile}".colorize(:green))
#        else
#          !puts("Error: Failed to build ISO Hybrid CD/USB bootable image:\n#{@vars.isofile}".colorize(:red)) and exit
#        end
#      end
#    end
  end

  # Create the initramfs.img
  # which provides the boot environment we will install from
  # Params:
  # +returns+:: true on changed
#  def build_initramfs()
#    create_dir_structure
#    changed = false
#    initramfs_digests = File.join(@initramfs_work, 'digests')
#
#    puts("#{'-' * 80}\nBuilding initramfs image...\n#{'-' * 80}".colorize(:yellow))
#    if syncfiles(File.basename(@initramfs_work), @initramfs_src, @initramfs_work, initramfs_digests) or
#        not File.exist?(@initramfs_image)
#      changed |= true
#      installer = File.join(@initramfs_work, 'installer')
#      installer_conf = File.join(@initramfs_work, 'installer.conf')
#      mkinitcpio_conf = File.join(@initramfs_work, 'mkinitcpio.conf')
#
#      # Resolve template
#      @vars.groups = @spec[@k.layers].select{|x| x[@k.type] == @k.machine}
#        .map{|x| x[@k.groups] if x[@k.groups]}.compact.uniq * ','
#      Fedit.resolve(installer, @vars)
#
#      # Build initramfs image in build container
#      docker(@k.build, @k.build){|cont, home, cp, exec, execs, runuser|
#        cp["#{installer} #{cont}:/usr/lib/initcpio/hooks"]
#        cp["#{installer_conf} #{cont}:/usr/lib/initcpio/install/installer"]
#        cp["#{mkinitcpio_conf} #{cont}:/etc"]
#
#        puts("Creating #{@initramfs_image}...".colorize(:cyan))
#        initramfs = File.join('/root', File.basename(@initramfs_image))
#        kernelstr = `#{execs} ls /lib/modules`.split("\n").sort.first
#        puts("Using kernel: #{kernelstr}".colorize(:green))
#
#        exec["mkinitcpio -k #{kernelstr} -g #{initramfs}"]
#        cp["#{cont}:#{initramfs} #{@initramfs_image}"]
#        puts("Successfully built initramfs image #{@initramfs_image}".colorize(:green))
#      }
#    end
#
#    return changed
#  end

  # Deploy vagrant node/s
  # Params:
  # +layer+:: layer to deploy
  # +name+:: name to give the specific node/container being created
  # +run+:: run the container with default run
  # +exec+:: specific command to run in the container
  # +nodes+:: list of node ids to deploy
  # +ipv6+:: enable ipv6 on the node/s being deployed
  # +vagrantfile+:: export the vagrant file only
  # +force+:: deploy even if already exists
  def deploy(layer, name:nil, run:nil, exec:nil, nodes:nil, ipv6:nil, vagrantfile:nil, force:nil)
    puts("#{'-' * 80}\nDeploying layer '#{layer}'\n#{'-' * 80}".colorize(:yellow))
    create_dir_structure
    layer_yml = getlayer(layer)

    # Deploy vagrant VM
    #---------------------------------------------------------------------------
    if layer_yml[@k.type] == @k.machine
      uid, gid = Sys.drop_privileges

      # Check that vagrant is on the path and clean previously deployed VMs
      !puts("Ensure 'vagrant' https://www.vagrantup.com/downloads.html is in the path".colorize(:red)) and
        exit unless find_executable('vagrant')
      clean(vms:true)

      # Update vagrant box registry
      box = getimages(@type.box, layer:layer).keys.shift
      !puts("Error: no box found for #{layer}, please pack the box first".colorize(:red)) and exit unless box
      puts("Updating vagrant registry for '#{layer}'".colorize(:cyan))
      Sys.exec("#{@sudoinv}vagrant box add #{layer} #{box} --force")

      # Configure host-only network
      !puts("Ensure 'virtualbox' https://www.virtualbox.org/wiki/Downloads is in the path".colorize(:red)) and
        exit unless find_executable('vboxmanage')
      config_network = "#{@sudoinv}vboxmanage hostonlyif ipconfig "
      config_network += "#{@vars.netname} -ip #{@vars.netip} -netmask #{@vars.netmask}"
      if not Sys.exec(config_network, die:false)
        Sys.exec("#{@sudoinv}vboxmanage hostonlyif create")
        Sys.exec(config_network)
      end

      # Generate vagrant node parameters
      #---------------------------------------------------------------------------
      specs = []
      (nodes || [rand(2..254)]).each do |node|
        host = name || layer
        host = "#{host}#{node.to_s}".gsub(' ', '').gsub('-', '').gsub('_', '')
        spec = {
          host: host,
          ip: "#{@vars.netip[0..-2]}#{node}/24",
          box: layer,
          cpus: layer_yml[@k.vagrant][@k.cpus] || 1,
          ram: layer_yml[@k.vagrant][@k.ram] || 512,
          vram: layer_yml[@k.vagrant][@k.vram] || 8,
          net: @vars.netname,
          v3d: layer_yml[@k.vagrant][@k.v3d] || @k.off,
          ipv6: ipv6
        }
        specs << spec
        puts("Generating node: #{spec.to_s}".colorize(:cyan))
      end

      # Create Vagrantfile for deployment
      vagrantfile_path = File.join(@vagrantpath, 'Vagrantfile')
      FileUtils.cp(File.join(@packer_src, 'Vagrantfile'), vagrantfile_path)
      file_insert(vagrantfile_path, specs.map{|x| '  ' + x.to_s} * ",\n", regex:/nodes = \[/, offset:2)

      # Initialize a new vagrant instance
      #-----------------------------------------------------------------------
      if not vagrantfile
        puts("Initializing vagrant node from layer '#{layer}'".colorize(:cyan))
        vmpath = File.expand_path(FileUtils.mkdir_p(File.join(@vagrantpath, specs.first[:host])).shift)
        FileUtils.cp(vagrantfile_path, vmpath)
        File.delete(vagrantfile_path)

        # Weird UI issue in that X apps can't open display :0 until reboot
        Dir.chdir(vmpath)
        Sys.exec("#{@sudoinv}vagrant up")
        Sys.exec("#{@sudoinv}vagrant reload")
      end

      Sys.raise_privileges(uid, gid)

    # Deploy docker container
    #---------------------------------------------------------------------------
    elsif layer_yml[@k.type] == @k.container
      !puts("Error: must be executed as root".colorize(:red)) and
        exit unless Process.uid.zero?

      # Remove old 'live' images and/or skip if current
      image = evalimages!(@type.tgz, layer:layer, live:true, force:force)
      puts("Image #{image} already exists".colorize(:green)) if image

      # Load disk image if it exists
      if not image
        image = evalimages!(@type.tgz, layer:layer, live:false)
        image ? puts("Image #{image} exists importing".colorize(:green)) :
          !puts("Error: need to first build image '#{image}'".colorize(:red)) and exit
        Sys.exec("cat #{image} | docker import - #{File.basename(image, '.*')}:latest")
        image = File.basename(image, '.*')
      end

      # Run container
      #-------------------------------------------------------------------------
      if run or exec

        # Get docker params
        params = []
        layers = getlayers(layer).reverse[0..-2].each{|_layer|
          docker = getlayer(_layer)[@k.docker]
          params << docker[@k.vars] if docker[@k.vars]
        }

        # Resolve image variable
        # Ex: docker run --rm --name dev66 -h dev66 -e TERM=xterm build-1.0.59 bash -c "while :; do sleep 5; done"
        cont = name || 'dev'
        env = '' and @proxyenv.each{|k,v| env << "-e #{k}=#{v} " if v}
        params = exec ? "-it #{env} #{image} #{exec}" :
          (params << "#{image} #{layer_yml[@k.docker][@k.command]}").flatten * ' '
        begin
          Sys.exec("docker run --rm --name #{cont} --hostname #{cont} #{params}", die:false)
        ensure
          exists = `docker ps -a --format "{{.Names}}"`.split("\n").find{|x| x == cont}
          Sys.exec("docker kill #{cont}") if exists
        end
      end
    end
  end

  # Build the implicated layers
  # Params:
  # +target_layer+:: specific layer to build
  # +returns+:: true if changed
  def build_layers(target_layer)
    changed = false
    layers = @spec[@k.layers].map{|x| x[@k.layer]}
    !puts("Error: Layer 'build' name not allowed") and exit if layers.include?(@k.build)
    !puts("Error: Layer '#{target_layer}' doesn't exist".colorize(:red)) and
      exit unless (layers + [nil, @k.build]).include?(target_layer)
    layers = getlayers(target_layer).reverse
    create_dir_structure

    layers.each do |layer|
      layer_changed = false
      layer_deps = getlayers(layer)[1..-1]
      layer_src = File.join(@layerspath, layer)
      layer_work = FileUtils.mkdir_p(File.join(@workpath, layer)).shift
      layer_digests = File.join(layer_work, 'digests')
      layer_yml = getlayer(layer)
      layer_image = layer_yml[@k.type] == @k.machine ? File.join(@isoimagesdst, "#{layer}.sqfs") :
        File.join(@imagepaths.first, "#{layer}-#{@vars.release}.tgz")
      puts("#{'-' * 80}\nBuilding layer '#{layer}'\n#{'-' * 80}".colorize(:yellow))

      begin
        # Mount all dependent layers starting with base
        # Note: lowerdirs stacked from right to left (e.g. heavy, lite, base)
        if layer_deps.any?
          puts("Mount layer dependencies #{layer_deps} for layer '#{layer}'".colorize(:cyan))
          Sys.exec("mount -t overlay -o lowerdir=%s,upperdir=%s,workdir=%s none %s" %
            [layer_deps.map{|x| File.join(@workpath, x)} * ':', layer_work, @tmp_dir, layer_work])
        end

        # Install layer specific packages via pacman
        layer_changed |= installpkgs(layer, layer_yml, layer_work)

        # Copy over all layer data if it exists
        layer_changed |= syncfiles(layer, layer_src, layer_work, layer_digests)

        # Apply file manipulations
        if layer_changed or not File.exist?(File.join(layer_work, 'changed')) or not File.exist?(layer_image)
          layer_changed |= Change.apply(layer_yml[@k.changes] || [],
            OpenStruct.new({root: layer_work, vars: @vars}))
          File.open(File.join(layer_work, 'changed'), 'w'){|f|}
        end

        # Build layer image if needed
        if layer_changed or not File.exist?(layer_image)
          puts("Creating #{layer_image}...".colorize(:cyan))
          Sys.umount(layer_work, retries:10) if layer_yml[@k.type] == @k.machine
          relocate_tracking_files(layer_work)

          # Create squashfs image for machine layers
          if layer_yml[@k.type] == @k.machine
            Sys.exec("mksquashfs #{layer_work} #{layer_image} -noappend -comp xz -b 256K -Xbcj x86")

          # Create compressed tarball for container layers
          else
            Sys.exec("tar --numeric-owner --xattrs --acls -C #{layer_work} -czf #{layer_image} .")
          end

          puts("Successfully built #{layer_image}".colorize(:green))
          relocate_tracking_files(layer_work, restore:true)
          layer_changed |= true
        else
          puts("Image already built #{layer_image}".colorize(:green))
        end

      ensure
        # Ensure joined file system is unmounted
        Sys.umount(layer_work, retries:10)
      end
      changed |= layer_changed
    end

    return changed
  end

  # Install packages for the given layer
  # Params:
  # +layer+:: layer name to work with
  # +layer_yml+:: layer yaml to work with
  # +layer_work+:: the directory where to install the layer packages to
  # +returns+:: true if any packages were installed
  def installpkgs(layer, layer_yml, layer_work)
    msg = "Installing packages for '#{layer}'..."
    pkgfile = File.join(layer_work, 'packages')

    # Handle packages differently based on type
    #---------------------------------------------------------------------------
    all_pkgs = getpkgs(layer_yml)
    pkgs = {
      reg: all_pkgs.map{|x| x[@k.pkg] if not [x[@k.ignore], x[@k.offline]].any? and @repos.include?(x[@k.type])}.compact,
      aur: all_pkgs.map{|x| x[@k.pkg] if not [x[@k.ignore], x[@k.offline]].any? and x[@k.type] == @k.AUR}.compact,
      foreign: all_pkgs.map{|x| x[@k.pkg] if not [x[@k.ignore], x[@k.offline]].any? and x[@k.type] == @k.FOREIGN}.compact,
      gem: all_pkgs.map{|x| "GEM:#{x[@k.pkg]}" if x[@k.type] == @k.GEM}.compact,
      ignore: all_pkgs.map{|x| x[@k.pkg] if x[@k.ignore]}.compact,
      offline: all_pkgs.map{|x| x[@k.pkg] if x[@k.offline]}.compact,
      conflict: all_pkgs.map{|x| "CONFLICT:#{x[@k.conflict]}" if x[@k.conflict]}.compact
    }

    # Filter out already installed packages
    #---------------------------------------------------------------------------
    if File.exist?(pkgfile)
      puts("Filtering out packages that are already installed".colorize(:cyan))
      installed_pkgs = nil
      File.open(pkgfile){|f| installed_pkgs = f.readlines.map{|x| x.strip}}
      [:reg, :gem, :aur, :foreign, :offline, :conflict].each{|x|
        pkgs[x] = pkgs[x].select{|y| not installed_pkgs.include?(y)}}
    end

    # Install any missing packages
    #---------------------------------------------------------------------------
    if pkgs.any?{|k,v| v.any? if k != :conflict and k != :ignore}
      puts("#{msg}".colorize(:cyan))
      puts("Packages: #{pkgs[:reg]}")
      puts("Gem Pkgs: #{pkgs[:gem]}")
      puts("Aur Pkgs: #{pkgs[:aur]}")
      puts("Foreign Pkgs: #{pkgs[:foreign]}")
      puts("Ignore Pkgs: #{pkgs[:ignore]}")
      puts("Offline Pkgs: #{pkgs[:offline]}")
      puts("Conflict Pkgs: #{pkgs[:conflict]}")

      # pacstrap replacement
      pacstrap = ->(msg, diemsg, &block){
        begin
          # Copy over pacman databases from host system to avoid constant updates
          Sys.exec("pacman -Sy")
          Sys.exec("mkdir -m 0755 -p #{File.join(layer_work, 'var/lib/pacman')}")
          Sys.exec("cp -a /var/lib/pacman/sync #{File.join(layer_work, 'var/lib/pacman')}")

          # Install/download/remove packages as directed
          puts("#{msg} packages for '#{layer}'...".colorize(:cyan))
          !puts("Error: #{diemsg}".colorize(:red)) and exit unless block.call
        ensure
          Sys.umount(File.join(layer_work, 'dev'), retries: 10)
        end
      }

      # Remove these packages first
      if pkgs[:conflict].any?
        pacstrap.call("Removing conflicting", "Failed to remove packages"){
          conflicts = pkgs[:conflict].map{|x| x.split(':').last} * ' '
          next Sys.exec("pacman -Rn -r #{layer_work} -d -d --noconfirm #{conflicts}", die:false) || true}
      end

      # Install normal packages
      if pkgs[:reg].any?
        cmd = ['pacstrap', '-GMcd', layer_work, '--config', @pacman_conf, '--needed', *pkgs[:reg]]
        cmd += ['--ignore', pkgs[:ignore] * ','] if pkgs[:ignore].any?
        pacstrap.call("Installing regular", "Failed to install packages correctly"){
          next Sys.exec(cmd, env:@proxyenv)}
      end

      # Download offline packages for later installs
      if pkgs[:offline].any?
        pacstrap.call("Downloading offline", "Failed to download the packages correctly"){
          offline_dir = FileUtils.mkdir_p(File.join(layer_work, 'opt', 'offline')).shift
          next Sys.exec(['pacstrap', '-GMcd', layer_work, '--config', @pacman_conf, '--downloadonly',
            '--cachedir', offline_dir, *pkgs[:offline]], env:@proxyenv)}
      end

      # Build cache and install aur packages and/or foreign packages
      if pkgs[:aur].any? or pkgs[:foreign].any?
        pacstrap.call("Installing aur/foreign", "Failed to install packages correctly"){
          buildpkgs(layer, layer_yml, layer_work, pkgs[:aur] + pkgs[:foreign])
          next Sys.exec(['pacstrap', '-GMcd', layer_work, '--config', @pacman_aur_conf, '--needed',
            *(pkgs[:aur] + pkgs[:foreign])], env:@proxyenv)}
      end

      # Install ruby gems
      if pkgs[:gem].any?
        pkgs[:gem].each{|x| installgem(x.split(':').last, true, layer_yml[@k.type], layer_work)}
      end

      # Clean up left artifacts from installs to leave prestine layer
      puts("Cleaning up artifacts that may be left over from installs".colorize(:cyan))
      Sys.exec("find #{layer_work} -name *.pacnew -name *.pacsave -name *.pacorig -delete")

      # Remove pacman transient data
      Sys.exec("find #{File.join(layer_work, 'var/lib/pacman')} -maxdepth 1 -type f -delete")
      rm_rf(File.join(layer_work, 'var/lib/pacman/sync/*'))

      # Remove all files from logging or packaging but leave empty dirs
      Sys.exec("find #{File.join(layer_work, 'var/log')} -type f -delete")
      Sys.exec("find #{File.join(layer_work, 'var/cache/pacman/pkg')} -type f -delete")

      # Remove pacman GnuPG keys for a fresh start
      rm_rf(File.join(layer_work, 'etc/pacman.d/gnupg'))

      # Remove all temporary files and dirs
      rm_rf(File.join(layer_work, 'var/tmp/*'))
      rm_rf(File.join(layer_work, 'tmp/*'))

      # Avoid "Failed to start Create Volatile Files and Directories"
      rm_rf(File.join(layer_work, 'var/log/journal'))

      # Update list of packages that were installed
      File.open(pkgfile, 'a'){|f| [:reg, :gem, :aur, :foreign, :offline].each{|x| f.puts(pkgs[x])}}
    else
      puts("#{msg}skipping".colorize(:cyan))
    end

    return pkgs.any?{|k,v| v.any? if k != :conflict and k != :ignore}
  end

  # Install the indicated gem
  # Params:
  # +gem+:: gem to install
  # +build+:: build in container if true or nil
  # +layer_type+:: layer type we're working with
  # +layer_work+:: layer's work directory where files are located
  # +returns+:: true on change
  def installgem(gem, build, layer_type, layer_work)
    changed = false
    gempath = File.join(@gemscache, gem)

    # Build gem in build container then extract and install to target
    if build or build == nil
      if not Dir[File.join(@gemscache, "#{gem}*")].any?
        docker(@k.build, @k.build){|cont, home, cp, exec, execs, runuser|
          params = "--no-document --install-dir=/ruby/gems --bindir=/ruby/bin"
          exec["gem install #{gem} --no-user-install #{params}"]
          cp["#{cont}:/ruby #{File.join(@gemscache, gem)}"]
        }
      end

      # Copy gem to chrooted layer
      if not `chroot #{layer_work} gem list`.include?(gem)
        gemdir = `chroot #{layer_work} gem environment gemdir`
        File.exist?(File.join(@gemscache, gem, 'bin')) and
          Sys.exec("cp -r #{File.join(@gemscache, gem, 'bin/*')} #{File.join(layer_work, '/usr/bin')}")
        Sys.exec("cp -r #{File.join(@gemscache, gem, 'gems/*')} #{File.join(layer_work, gemdir)}")
      end

    # Fetch locally cache then install gem to target
    else
      Sys.exec("cd #{@gemscache} && gem fetch #{gem}") if not Dir[File.join(@gemscache, "#{gem}*")].any?
      gempath = Dir[File.join(@gemscache, "#{gem}*")].first

      # Install gem into chrooted layer
      if not `chroot #{layer_work} gem list`.include?(gem)
        Sys.exec("cp #{gempath} #{File.join(layer_work, 'tmp')}")
        gempath = File.join('/tmp', File.basename(gempath))
        params = "--no-user-install#{layer_type == @k.container ? ' --no-ri --no-rdoc' : ''}"
        Sys.exec("chroot #{layer_work} gem install --local #{gempath} #{params}")
        Sys.exec("chroot #{layer_work} rm #{gempath}")
        changed |= true
      end
    end

    return changed
  end

  # Build packages
  # Params:
  # +layer+:: layer name to work with
  # +pkgs+:: packages to build
  # +layer_yml+:: layer yaml to work with
  # +layer_work+:: the directory where to install the layer packages to
  def buildpkgs(layer, layer_yml, layer_work, pkgs)
    changed = false
    aur_database = File.join(@aurcache, 'aur.db.tar.gz')

    # Generate pacman.conf from existing arch specific pacman config
    FileUtils.cp(@pacman_conf, @pacman_aur_conf)
    Fedit.replace(@pacman_aur_conf, /(IgnorePkg\s*=.*)/, '#\1')
    Fedit.replace(@pacman_aur_conf, /#\[custom\]/, '[aur]')
    Fedit.replace(@pacman_aur_conf, /#(SigLevel = Optional.*)/, '\1')
    Fedit.replace(@pacman_aur_conf, /#(Server = file).*/, "\\1://#{@aurcache}")

    # Filter out cached packages
    cached = Dir[File.join(@aurcache, '*.xz')].map{|x| File.basename(x).split('.').first.split('-')[0..-2]}
      .map{|x| x.select{|y| not y[0] =~ /[0-9]/} * '-'}.sort
    pkgs.reject!{|x| cached.include?(x)}

    # Build AUR/FOREIGN packages in build container
    if pkgs.any?
      !puts("Error: automated package building not yet supported!".colorize(:red)) and exit

      docker(@k.build, @k.build){|cont, home, cp, exec, execs, runuser|
        pkgs.each{|pkg|
          pkgdir = "#{home}/#{pkg}"
          foreign = File.exist?(File.join(@aurpath, pkg))
          puts("Building #{foreign ? 'FOREIGN':'AUR'} package '#{pkg}'...".colorize(:cyan))

          # Erase local build if necessary
          if Dir[File.join(@aurpath, pkg, '*.pkg.tar.xz')].first
            puts("Resetting forign package source #{File.join(@aurpath, pkg)}".colorize(:cyan))
            Sys.exec("#{@runuser} 'rm -rf #{File.join(@aurpath, pkg, '*')}'")
            Sys.exec("#{@runuser} 'git checkout #{File.join(@aurpath, pkg)}'")
          end

          # Prepare package specs
          if foreign
            cp["#{File.join(@aurpath, pkg)} #{cont}:#{home}"]
            exec["chown -R #{@k.build}:#{@k.build} #{pkgdir}"]
          else
            runuser["cd #{home} && yaourt -G #{pkg}"]
          end

          # Build package
          runuser["cd #{pkgdir} && makepkg -s --noconfirm --needed --nocheck"]

          # Extract package from container
          pkgname = `#{execs} ls #{pkgdir}`.split("\n")
            .find{|x| x.include?(pkg) and x.include?('pkg.tar.xz')}
          cp["#{cont}:#{pkgdir}/#{pkgname} #{@aurcache}"]
        }
      }

      # Remove old repo database info
      files = File.join(@aurcache, 'aur*')
      puts("Delete old aur database files #{files}".colorize(:cyan))
      rm_rf(files)
    else
      puts("All AUR/FOREIGN packages are already built and cached".colorize(:cyan))
    end

    # Create cached package repo
    if Dir[File.join(@aurcache, '*.xz')].any? and not File.exist?(aur_database)
      puts("Building cached aur repository database".colorize(:cyan))
      Sys.exec("repo-add #{aur_database} #{@aurcache}/*.xz")
    end

    return changed
  end

  # Get packages for the given layer
  # Params:
  # +layer_yml+:: layer yaml to work with or all if nil
  # +returns+:: list of packages for the given layer or all packages
  def getpkgs(layer_yml)
    result = {}
    layers = layer_yml ? [layer_yml] : @spec[@k.layers]

    # Detect multilib value
    multilib = layers.any?{|x| x[@k.multilib]}
    puts("Multilib: #{multilib} for #{layers.map{|x| "'#{x[@k.layer]}'"} * ','}".colorize(:cyan))

    # Get all packages for given layers
    layers.each{|layer|
      all_pkgs = (layer[@k.packages] || [])
      resolve_pkgsets = ->(pkgs){
        return pkgs.map{|x|
          if x[@k.install] || (x[@k.ignore] && !x[@k.pkg])
            pkgkey = x[@k.install] || x[@k.ignore]
            pkgset = Marshal.load(Marshal.dump(@spec[@k.packages][pkgkey]))
            !puts("Error: missing package set '#{pkgkey}'".colorize(:red)) and exit unless pkgset
            # TODO: when multilib=true and arch is i686 then do opposite
            pkgset.reject!{|y| multilib ? y[@k.multilib] == false : y[@k.multilib]} if x[@k.install]
            pkgset.each{|y| y[@k.ignore] = true } if x[@k.ignore]
            pkgset
          else
            x
          end
        }.flatten}
      (0..1).each{|i| all_pkgs = resolve_pkgsets[all_pkgs]}

      # Remove duplicates
      all_pkgs.uniq!

      result[layer[@k.layer]] = all_pkgs
    }

    return result.length == 1 ? result.values.first : result
  end

  # Spins up indicated container and executes the given block
  # in the container then terminates the container.
  # +layer+:: container to use
  # +user+:: user to work with
  # +block+:: block of code to execute
  # Params:
  def docker(layer, user, &block)

    # Spin up given container and wait for it to be ready
    #---------------------------------------------------------------------------
    cont = "dev#{rand(10..99)}"
    thread = Thread.new{deploy(layer, name:cont, run:true)}
    (1..100).each{|i|
      if not `docker ps`.include?(cont)
        puts("Waiting for container '#{cont}' to be ready...") if i % 2 == 0
        sleep(1)
      else
        break
      end
    }

    # Execute in container
    #---------------------------------------------------------------------------
    vars = '' and @proxyenv.each{|k,v| vars << "export #{k}=#{v} && " if v}
    home = user == 'root' ? "/root" : "/home/#{user}"
    cp = ->(cmd){Sys.exec("docker cp #{cmd}")}
    exec = ->(cmd){Sys.exec("docker exec #{cont} bash -c \"#{vars}#{cmd.gsub(/"/, '\"')}\"")}
    execs = "docker exec #{cont}"
    runuser = ->(cmd){Sys.exec("docker exec #{cont} runuser #{user} -c \"#{vars}#{cmd.gsub(/"/, '\"')}\"")}
    block.call(cont, home, cp, exec, execs, runuser)

    # Shutdown container
    #---------------------------------------------------------------------------
    thread.kill
    thread.join
  end

  # Syncs the source and work directories for a given layer
  # +layer+:: layer to work with
  # +layer_src+:: layer source directory to work with
  # +layer_work+:: layer work directory to work with
  # +layer_digests+:: layer digests file
  # +block+:: block of code to execute
  # Params:
  def syncfiles(layer, layer_src, layer_work, layer_digests, &block)
    changed = false
    return changed if not File.exist?(layer_src)

    msg = "Syncing from #{layer_src}"
    files = Dir.glob(File.join(layer_src, '**/*'), File::FNM_DOTMATCH).reject{|x| File.directory?(x)}
    newfiles, modifiedfiles, deletedfiles = Fedit.digests_changed(layer, layer_digests, files)
    if newfiles.any? or modifiedfiles.any? or deletedfiles.any? or not File.exist?(layer_digests)
      changed |= true
      puts(msg.colorize(:cyan))

      # Remove files that no longer exist from layer directory not data
      deletedfiles.each{|x|
        target = x.sub(layer_src, layer_work)
        puts("Deleting #{target}".colorize(:red))
        File.delete(target)
      }

      # Copy over files from data dir to layer dir
      if File.exist?(layer_src)
        files.each{|x|
          puts("Copying: #{x.sub(layer_src, '...')}")
          FileUtils.mkdir_p(File.dirname(x.sub(layer_src, layer_work)))
          FileUtils.cp(x, x.sub(layer_src, layer_work))}
      end

      # Copy user files to root as well
      skelpath = File.join(layer_src, 'etc/skel')
      if File.exist?(skelpath)
        puts("Copying from #{skelpath}".colorize(:cyan))
        Dir.glob(File.join(skelpath, '/**/*'), File::FNM_DOTMATCH).reject{|x| File.directory?(x)}.each{|x|
          puts("Copying: #{x.sub(layer_src, '...')} => #{x.sub(skelpath, '.../root')}")
          FileUtils.mkdir_p(File.dirname(x.sub(layer_src, layer_work).sub('etc/skel', 'root')))
          FileUtils.cp(x, x.sub(layer_src, layer_work).sub('etc/skel', 'root'))}
      end

      # Execute block
      block.call if block

      # Update digests
      Fedit.update_digests(layer, layer_digests, files)
    else
      puts("#{msg}skipping".colorize(:cyan))
    end

    puts("Completed constructing/modifiying files for '#{layer}' layer".colorize(:green))

    return changed
  end

  # Evaluate images matching type and layer; removing if stale
  # Params:
  # +type+:: image type to get
  # +layer+:: layer to get image for or all
  # +live+:: evaluate live(true) vs disk(false)
  # +force+:: remove images matching conditions
  # +returns+:: image matching the version
  def evalimages!(type, layer:nil, live:nil, force:nil)
    image_exists = nil
    curver = @vars.release.split('.').map{|x| x.to_i}

    getimages(type, layer:layer, live:live).keys.each{|image|
      puts("Evaluating '#{live ? 'live' : 'disk'}' image #{image}".colorize(:cyan))
      name = live ? image[/-(.*)/, 1] : image[/-(.*?)\.#{type}/, 1]
      imagever = name.split('.').map{|x| x.to_i}
      if force or (imagever <=> curver) == -1
        puts("Removing image '#{live ? 'live' : 'disk'}' #{image} - #{force ? 'forced' : 'outdated'}".colorize(:red))
        if not live
          File.delete(image)
        elsif type == @type.tgz

          # Remove any old containers that depend on that image
          cntrs = `sudo docker ps -a --format "{{.Image}}:{{.ID}}"`.split("\n")
            .select{|x| x.start_with?(image)}
          cntrs.each{|x| Sys.exec("sudo docker rm #{x.split(':')[1]}")}

          # Remove image
          Sys.exec("sudo docker rmi #{image} --force")
        end
      else
        image_exists = image
      end
    }

    return image_exists
  end

  # Get all images sorted newest to oldest
  # Params:
  # +type+:: image type to get
  # +layer+:: layer to get image for or all
  # +live+:: get live(true) vs disk(false)
  # +die+:: die on error
  # +returns+:: all images sorted by version and optionally filtered by layer
  def getimages(type, layer:nil, live:nil, die:false)
    image_maps = {}

    # Get deployed image data
    #---------------------------------------------------------------------------
    if live and type == @type.tgz
      images = {}
      `sudo docker images --format "{{.Repository}}:{{.Size}}"`.split("\n")
        .select{|x| layer ? x.start_with?("#{layer}-") : true }
        .map{|x| x.split(':')}.each{|x| images[x.first] = x.last}
      images.keys.sort_by{|x| (x[/-(\d+\.\d+\.\d+).*/, 1] || "<none>.").split('.').map{|y| y.to_i} }
        .reverse!.each{|x| image_maps[x] = images[x]}

    # Get disk image data
    #---------------------------------------------------------------------------
    elsif not live
      images = []
      @imagepaths.each{|path|
        files = File.exist?(path) ? Dir[File.join(path, "*.#{type}")] : []
        images += layer ? files.select{|x| x.include?(layer)} : files}
      images = [@type.sqfs, @type.img].include?(type) ? images.sort :
        images.delete_if{|x| !x.include?(@vars.distro)}
          .sort_by{|x| x[/-(\d+\.\d+\.\d+).*/, 1].split('.').map{|y| y.to_i}}.reverse
      images.each{|x| image_maps[x] = File.size(x)}
    end

    # Print result for single search
    if layer and image_maps.keys.first
      puts("Located '#{live ? 'live' : 'disk'}' image #{image_maps.keys.first}".colorize(:cyan))
    elsif layer and die
      !puts("Could not find image type '#{type}' for '#{layer}'".colorize(:red)) and exit
    end

    return image_maps
  end

  # Relocate the tracking files
  # Params:
  # +layer_work+:: directory to get tracking files from
  # +restore+:: move the relocated files back to their original location
  # +returns+:: image matching the version
  def relocate_tracking_files(layer_work, restore:false)
    digests = File.join(layer_work, 'digests')
    packages = File.join(layer_work, 'packages')
    changed = File.join(layer_work, 'changed')
    if not restore
      FileUtils.mv(digests, @tmp_dir) if File.exist?(digests)
      FileUtils.mv(packages, @tmp_dir) if File.exist?(packages)
      FileUtils.mv(changed, @tmp_dir) if File.exist?(changed)
    end

    _digests = File.join(@tmp_dir, File.basename(digests))
    _packages = File.join(@tmp_dir, File.basename(packages))
    _changed = File.join(@tmp_dir, File.basename(changed))
    if restore
      FileUtils.mv(_digests, layer_work) if File.exist?(_digests)
      FileUtils.mv(_packages, layer_work) if File.exist?(_packages)
      FileUtils.mv(_changed, layer_work) if File.exist?(_changed)
    end
  end

  # Get layer dependencies
  # Params:
  # +layer+:: the layer to get dependencies for
  # +returns+:: list of layers (e.g. heavy => heavy, lite, shell, base)
  def getlayers(layer)
    return nil if not getlayer(layer)

    layers = [layer]
    return layers if layer == @k.build

    _layer = layer
    while _layer
      _layer = @spec[@k.layers].find{|x| x[@k.layer] == _layer}[@k.base]
      layers << _layer if _layer
    end

    return layers
  end

  # Get layer yaml by layer name
  # Params:
  # +layer+:: layer name to get yaml for
  # +returns+:: yaml for the indicated layer
  def getlayer(layer)
    return layer == @k.build ? @spec[@k.build] :
      @spec[@k.layers].find{|x| x[@k.layer] == layer}
  end

end

#-------------------------------------------------------------------------------
# Main entry point
#-------------------------------------------------------------------------------
if __FILE__ == $0
  app = 'reduce'
  reduce = Reduce.new
  version = reduce.instance_variable_get(:@vars).release
  examples = "Machine Examples:\n".colorize(:green)
  examples += "Full ISO Build: sudo ./#{app}.rb clean build --iso-full\n".colorize(:green)
  examples += "Build k8snode layer: sudo ./#{app}.rb clean build --layers=k8snode --iso\n".colorize(:green)
  examples += "Pack k8snode layer: ./#{app}.rb pack --layers=k8snode\n".colorize(:green)
  examples += "Deploy nodes: sudo ./#{app}.rb deploy --layer=k8snode --nodes=10,11,12\n".colorize(:green)
  examples += "\n"

  opts = Cmds.new(app, version, examples)
  opts.add('info', 'List build info', [
    CmdOpt.new('--all', 'List all info'),
    CmdOpt.new('--aur-pkgs', 'List all aur packages'),
    CmdOpt.new('--foreign-pkgs', 'List all foreign packages'),
  ])
  opts.add('list', 'List out components', [
    CmdOpt.new('--all', 'List all components'),
    CmdOpt.new('--boxes', 'List all boxes'),
    CmdOpt.new('--isos', 'List all isos'),
    CmdOpt.new('--images', 'List all docker images'),
    CmdOpt.new('--spec', 'List out the resolved spec'),
  ])
  opts.add('clean', 'Clean ISO components', [
    CmdOpt.new('--all', 'Clean all components'),
    CmdOpt.new('--initramfs', 'Clean initramfs image'),
    CmdOpt.new('--isolinux', 'Clean isolinux boot'),
    CmdOpt.new('--layers=x,y,z', 'Clean given layers', type:Array),
    CmdOpt.new('--iso', 'Clean bootable ISO'),
    CmdOpt.new('--iso-full', 'Clean bootable ISO and all machine layers'),
    CmdOpt.new('--vms', 'Clean VMs that are no longer deployed'),
  ])
  opts.add('build', 'Build ISO components', [
    CmdOpt.new('--initramfs', 'Build initramfs image'),
    CmdOpt.new('--isolinux', 'Build isolinux boot'),
    CmdOpt.new('--layers=x,y,z', 'Build given layers', type:Array),
    CmdOpt.new('--iso', 'Build USB bootable ISO with existing layers'),
    CmdOpt.new('--iso-full', 'Build USB bootable ISO with all machine layers'),
  ])
  opts.add('deploy', 'Deploy VMs or containers', [
    CmdOpt.new('--layer=LAYER', 'Deploy a specific layer VM', type:String, required:true),
    CmdOpt.new('--name=NAME', 'Give a name to the specific node being deployed', type:String),
    CmdOpt.new('--run', 'Run default container run'),
    CmdOpt.new('--exec=CMD', 'Specific command to run in container', type:String),
    CmdOpt.new('--nodes=x,y,z', 'Comma delimited list of last octet IPs (e.g. 10,11,2)', type:Array),
    CmdOpt.new('--force', 'Deploy the given layer/s even if already exists'),
    CmdOpt.new('--ipv6', 'Enable ipv6 on the given nodes'),
    CmdOpt.new('--vagrantfile', 'Export the Vagrantfile only'),
  ])
  opts.parse!

  # Execute
  puts(opts.banner)

  # Execute 'info' command
  reduce.info(aurpkgs: opts[:aurpkgs], foreignpkgs: opts[:foreignpkgs],
    all: opts[:all]) if opts[:info]

  # Execute 'list' command
  reduce.list(boxes: opts[:boxes], isos: opts[:isos], images: opts[:images],
    spec: opts[:spec], all: opts[:all]) if opts[:list]

  # Execute 'clean' command
  reduce.clean(initramfs: opts[:initramfs], isolinux: opts[:isolinux],
    layers: opts[:layers], iso: opts[:iso], vms: opts[:vms], all: opts[:all],
    isofull: opts[:isofull]) if opts[:clean]

  # Execute 'build' command
  reduce.build(initramfs: opts[:initramfs], isolinux: opts[:isolinux],
    layers: opts[:layers], iso: opts[:iso], isofull: opts[:isofull]) if opts[:build]

  # Execute 'deploy' command
  reduce.deploy(opts[:layer], name: opts[:name], run: opts[:run], exec: opts[:exec], nodes: opts[:nodes],
    ipv6: opts[:ipv6], vagrantfile: opts[:vagrantfile], force: opts[:force]) if opts[:deploy]
end

# vim: ft=ruby:ts=2:sw=2:sts=2
