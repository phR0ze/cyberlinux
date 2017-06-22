#!/usr/bin/env ruby
require 'erb'                   # leverage erb for templating
require 'digest'                # work with digests
require 'fileutils'             # advanced file utils: FileUtils
require 'mkmf'                  # system utils: find_executable
require 'open-uri'              # easily read HTTP
require 'optparse'              # cmd line options: OptionParser
require 'ostruct'               # OpenStruct
require 'open3'                 # Better system commands
require 'rubygems/package'      # tar
require 'yaml'                  # YAML

require_relative 'lib/erb'      # ERB Handlers for different types
require_relative 'lib/edit'     # Programatic file editor

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

  # Meta programming
  # https://www.toptal.com/ruby/ruby-metaprogramming-cooler-than-it-sounds
  def initialize
    @type = OpenStruct.new({
      img: 'img',
      iso: 'iso',
      box: 'box',
      tgz: 'tgz',
      sqfs: 'sqfs'
    })
    @k = OpenStruct.new({
#      after: 'after',
#      append: 'append',
#      apply: 'apply',
#      AUR: 'AUR',
      base: 'base',
      build: 'build',
#      changes: 'changes',
#      chown: 'chown',
#      chroot: 'chroot',
#      conflict: 'conflict',
#      container: 'container',
#      cpus: 'cpus',
#      desc: 'desc',
#      digests: 'digests',
#      edit: 'edit',
#      exec: 'exec',
#      enable: 'enable',
#      entries: 'entries',
#      FOREIGN: 'FOREIGN',
#      GEM: 'GEM',
#      gfxboot: 'gfxboot',
#      groups: 'groups',
      i686: 'i686',
#      ignore: 'ignore',
#      initrd: 'initrd',
#      install: 'install',
#      isolinux: 'isolinux',
#      kernel: 'kernel',
#      label: 'label',
      layer: 'layer',
      layers: 'layers',
#      link: 'link',
#      links: 'links',
#      machine: 'machine',
#      multilib: 'multilib',
#      name: 'name',
#      noboot: 'noboot',
#      off: 'off',
#      offline: 'offline',
#      pkg: 'pkg',
#      packages: 'packages',
#      ram: 'ram',
#      regex: 'regex',
#      repo: 'repo',
#      repos: 'repos',
#      resolve: 'resolve',
#      run: 'run',
#      service: 'service',
#      type: 'type',
#      v3d: 'v3d',
#      vagrant: 'vagrant',
#      value: 'value',
#      values: 'values',
#      vram: 'vram',
#      vars: 'vars',
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

  end

  def build()
    puts("Hello build")
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

  # Drop root privileges to original user
  # Only affects ruby commands not system commands
  # Params:
  # +returns+:: uid, gid of prior user
  def drop_privileges()
    uid = gid = nil

    if not Gem.win_platform? and Process.uid.zero?
      uid, gid = Process.uid, Process.gid
      sudo_uid, sudo_gid = ENV['SUDO_UID'].to_i, ENV['SUDO_GID'].to_i
      Process::Sys.setegid(sudo_uid)
      Process::Sys.seteuid(sudo_gid)
    end

    return uid, gid
  end

  # Raise privileges if dropped earlier
  # Only affects ruby commands not system commands
  # Params:
  # +uid+:: uid of user to assume
  # +gid+:: gid of user to assume
  def raise_privileges(uid, gid)
    if not Gem.win_platform? and uid and gid
      Process::Sys.seteuid(uid)
      Process::Sys.setegid(gid)
    end
  end
end

#-------------------------------------------------------------------------------
# Main entry point
#-------------------------------------------------------------------------------
if __FILE__ == $0
  opts = {}
  app = 'reduce'

  # Configure command line options
  #-------------------------------------------------------------------------------
  help = <<HELP
  Commands available for use:
      build                            Build ISO components

  see './#{app}.rb COMMAND --help' for specific command info
HELP

  optparser = OptionParser.new do |parser|
    banner = "#{app}\n#{'-' * 80}\n".colorize(:yellow)
    examples = "Examples:\n".colorize(:green)
    examples += "Build: sudo ./#{app}.rb clean build --iso-full\n".colorize(:green)
    parser.banner = "#{banner}#{examples}\nUsage: ./#{app}.rb commands [options]"
    parser.on('-h', '--help', 'Print command/options help') {|x| !puts(parser) and exit }
    parser.separator(help)
  end

  optparser_cmds = {
    'build' => [OptionParser.new{|parser|
      parser.banner = "Usage: ./#{app}.rb build [options]"
      parser.on('--iso', "Build USB bootable ISO from existing '_iso_' workspace") {|x| opts[:iso] = x}
    }]
  }

  # Evaluate command line args
  ARGV.clear and ARGV << '-h' if ARGV.empty? or not optparser_cmds[ARGV[0]]
  optparser.order!
  cmds = ARGV.select{|x| not x.include?('--')}
  ARGV.reject!{|x| not x.include?('--')}
  cmds.each{|x| !puts("Error: invalid command '#{x}'".colorize(:red)) and exit unless optparser_cmds[x]}
  cmds.each do |cmd|
    begin
      opts[cmd.to_sym] = true
      optparser_cmds[cmd].first.order!
    rescue OptionParser::InvalidOption => e

      # Re-set chain options
      if optparser_cmds[cmd].last.any?{|x| e.to_s.include?(x)}
        optparser_cmds[cmd].last.select{|x| e.to_s.include?(x)}.each{|x|
          ARGV << e.to_s[/(--#{x}.*)/, 1]}
      # Print help
      else
        puts("Error: #{e}".colorize(:red))
        !puts(optparser_cmds[cmd].first.help) and exit
      end
    end
  end

  # Check required options
  if ARGV.any?
    !puts("Error: unhandled arguments #{ARGV}".colorize(:red)) and exit
  end

  #-------------------------------------------------------------------------------
  # Execute application
  #-------------------------------------------------------------------------------
  reduce = Reduce.new

  # Process 'build' command
  if opts[:build]
    help = nil
    !puts(help.colorize(:red)) and !puts(optparser_cmds['build'].help) and exit if help

    reduce.build
  end
end

# vim: ft=ruby:ts=2:sw=2:sts=2
