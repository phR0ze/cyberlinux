#!/usr/bin/env ruby
require 'erb'                   # leverage erb for templating
require 'digest'                # work with digests
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
      FOREIGN: 'FOREIGN',
      i686: 'i686',
      ignore: 'ignore',
      install: 'install',
      layer: 'layer',
      layers: 'layers',
      machine: 'machine',
      multilib: 'multilib',
      pkg: 'pkg',
      packages: 'packages',
      type: 'type',
      vars: 'vars',
      x86_64: 'x86_64',
    })
    @rootpath = File.dirname(File.expand_path(__FILE__))
    @spec_file = File.join(@rootpath, 'spec.yml')
    @spec = YAML.load_file(@spec_file)
    @vars = OpenStruct.new(@spec[@k.vars])
    @user = Gem.win_platform? ? '' : Process.uid.zero? ? Etc.getpwuid(ENV['SUDO_UID'].to_i).name : ENV['USER']
    @runuser = "runuser #{@user} -c"
    @sudoinv = Gem.win_platform? ? '' : Process.uid.zero? ? "sudo -Hu #{@user} " : ''

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
    #@repos = @spec[@k.repos].map{|x| x[@k.repo].upcase} << nil
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
    if live and type == @type.tgz and not Gem.win_platform?
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

  opts = Cmds.new(app, version, examples)
  opts.add('info', 'List build info', [
    CmdOpt.new('--all', 'List all info'),
    CmdOpt.new('--aur-pkgs', 'List all aur packages'),
    CmdOpt.new('--foreign-pkgs', 'List all foreign packages')
  ])
  opts.add('list', 'List out components', [
    CmdOpt.new('--all', 'List all components'),
    CmdOpt.new('--boxes', 'List all boxes'),
    CmdOpt.new('--isos', 'List all isos'),
    CmdOpt.new('--images', 'List all docker images'),
    CmdOpt.new('--spec', 'List out the resolved spec'),
  ])
  opts.add('build', 'Build ISO components', [
    CmdOpt.new('--iso', 'Build USB bootable ISO with existing layers'),
    CmdOpt.new('--iso-full', 'Build USB bootable ISO with all machine layers'),
  ])
  opts.parse!

  # Execute
  puts(opts.banner)
  reduce.info(aurpkgs: opts[:aurpkgs], foreignpkgs: opts[:foreignpkgs],
    all: opts[:all]) if opts[:info]
  reduce.list(boxes: opts[:boxes], isos: opts[:isos], images: opts[:images],
    spec: opts[:spec], all: opts[:all]) if opts[:list]
  reduce.build(iso: opts[:iso], isofull: opts[:isofull]) if opts[:build]
end

# vim: ft=ruby:ts=2:sw=2:sts=2
