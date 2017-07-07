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

require 'optparse'              # cmd line options: OptionParser
require 'yaml'                  # YAML

begin
  require 'colorize'        # color output: colorize
rescue Exception => e
  gem = e.message.split(' ').last.sub('/', '-')
  !puts("Error: install missing gem with 'sudo gem install --no-user-install #{gem}'") and exit
end

class CmdOpt
  attr_reader(:key)
  attr_reader(:conf)
  attr_reader(:type)
  attr_reader(:desc)
  attr_reader(:required)
  def initialize(conf, desc, type:nil, required:false)
    @conf = conf.gsub(' ', '=')
    @key = conf.gsub('-', '').split('=').first.to_sym
    @type = type
    @desc = desc
    @required = required
  end
end

# Simple command wrapper around options parsing
# When multiple commands are given they share the options passed along with them
class Cmds

  # Option and command names have all hyphens removed
  attr_accessor(:cmds)
  attr_accessor(:opts)

  # Initialize the commands for your application
  # Params:
  # +app+:: application name e.g. reduce
  # +version+:: version of the application e.g. 1.0.0
  # +examples+:: optional examples to list after the title before usage
  def initialize(app, version, examples)
    @opts = {}
    @cmds = {}
    @cmds_config = {}

    @app = app
    @version = version
    @examples = examples || ''
  end

  # Array like accessor for checking if a command is set
  def [](key)
    return @cmds[key] if @cmds[key]
    return @opts[key] if @opts[key]
  end

  # Add a command to the command list
  # Params:
  # +cmd+:: name of the command
  # +desc+:: description of the command
  # +opts+:: list of command options
  def add(cmd, desc, opts)
    @cmds_config[cmd] = {desc: desc, inopts: opts, outopts: OptionParser.new{|parser|
      required = opts.map{|x| x.conf if x.required}.compact * ' '
      required += ' ' if not required.empty?
      parser.banner = "#{banner}\nUsage: ./#{@app} #{cmd} #{required}[options]"
      opts.each{|opt| parser.on(opt.conf, opt.type, opt.desc){|x| @opts[opt.key] = x }}
    }}
  end

  # Returns banner string
  def banner
    banner = "#{@app}_v#{@version}\n#{'-' * 80}".colorize(:yellow)
    return banner
  end

  # Construct the command line parser and parse
  def parse!

    # Construct help for the application
    help = "COMMANDS:\n"
    @cmds_config.each{|k,v| help += "    #{k.ljust(33, ' ')}#{v[:desc]}\n" }
    help += "\nsee './#{@app} COMMAND --help' for specific command info"

    # Construct top level option parser
    @optparser = OptionParser.new do |parser|
      parser.banner = "#{banner}\n#{@examples}Usage: ./#{@app} commands [options]"
      parser.on('-h', '--help', 'Print command/options help') {|x| !puts(parser) and exit }
      parser.separator(help)
    end

    # Invoke the option parser with help if any un-recognized commands are given
    cmds = ARGV.select{|x| not x.start_with?('-')}
    ARGV.clear and ARGV << '-h' if ARGV.empty? or cmds.any?{|x| not @cmds_config[x]}
    cmds.each{|x| puts("Error: Invalid command '#{x}'".colorize(:red)) if not @cmds_config[x]}
    @optparser.order!

    # Now remove them from ARGV leaving only options
    ARGV.reject!{|x| not x.start_with?('-')}

    # Parse each command which will consume options from ARGV
    cmds.each do |cmd|
      begin
        @cmds[cmd.to_sym] = true
        @cmds_config[cmd][:outopts].order!

        # Ensure that all required options were given
        @cmds_config[cmd][:inopts].each{|x|
          if x.required and not @opts[x.key]
            puts("Error: Missing required option '#{x.key}'".colorize(:red))
            ARGV.clear and ARGV << "-h"
            @cmds_config[cmd][:outopts].order!
          end
        }
      rescue OptionParser::InvalidOption => e
        # Options parser will raise an invalid exception if it doesn't recognize something
        # However we want to ignore that as it may be another command's option
        ARGV << e.to_s[/(-.*)/, 1]
      end
    end

    # Ensure all options were consumed
    !puts("Error: invalid options #{ARGV}".colorize(:red)) and exit if ARGV.any?
  end
end

# vim: ft=ruby:ts=2:sw=2:sts=2
