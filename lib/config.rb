#!/usr/bin/env ruby
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

require 'fileutils'
require 'ostruct'

require_relative 'core'
require_relative 'fedit'

module Config
  extend self

  # Get config keys
  # Params:
  # +returns+:: OpenStruct of all the string keys being used for configs
  def keys
    return OpenStruct.new({
      after: 'after',
      apply: 'apply',
      append: 'append',
      before: 'before',
      chroot: 'chroot',
      edit: 'edit',
      entry: 'entry',
      exec: 'exec',
      label: 'label',
      menu: 'menu',
      regex: 'regex',
      resolve: 'resolve',
      value: 'value',
      values: 'values'

    })
  end

  # Apply the given config
  # This is the only method that can directly deal with configs and is meant to be the entry point
  # for all configs. Other methods surfaced in this module are only exposed for simplicity.
  # @param config [list] of yaml blocks describing the configs
  # @param ctx [OpenStruct] containing 'root' directory, 'vars', configs
  # @param returns true on change
  def apply(configs, ctx)
    changed = false
    configs = [configs] if not configs.is_a?(Array)
    k = Config.keys
    configs.each{|config|

      # Recurse on config references
      if config[k.apply]
        puts("Applying '#{config[k.apply]}'")
        begin
          changed |= apply(ctx.configs[config[k.apply]], ctx)
        rescue
          puts("Failed to find the config referenced by '#{config[k.apply]}'")
          raise
        end

      # Apply the config
      else

        # Resolve templating in the actual config
        config = config.erb(ctx.vars)

        # Redirect paths as required
        config = Config.redirect(config, ctx, k) if not config[k.chroot]

        # Apply bash scripts
        if config[k.chroot]
          Sys.exec("arch-chroot #{ctx.root} #{config[k.chroot]}")

        # Apply file edits
        elsif config[k.edit]
          file = config[k.edit]
          puts("Editing: #{file}")
          values = config[k.value] ? [config[k.value]] : config[k.values]
          FileUtils.mkdir_p(File.dirname(file)) if not File.exist?(File.dirname(file))

          if not File.exist?(file)
            changed |= Fedit.insert(file, values)
          else
            append = config[k.append]

            # Check if the configs have already been made
            data = File.binread(file)
            already = values.all?{|y| data =~ Regexp.new(Regexp.quote(y))}

            # Regex replacements
            if not append
              changed |= Fedit.replace(file, config[k.regex], values.first)

            # File insert/appends
            elsif not already
              offset = append == true ? nil : append == k.after ? 1 : 0
              changed |= Fedit.insert(file, values, regex:config[k.regex], offset:offset)
            end
          end

        # Apply menu entries
        elsif config[k.menu]
          add_menu_entry(config, ctx, k)

        # Apply bash scripts
        elsif config[k.exec]
          Sys.exec(config[k.exec])

        # Resolve template
        elsif config[k.resolve]
          changed |= Fedit.resolve(config[k.resolve], ctx.vars)
        end
      end
    }

    return changed
  end

  # Add a menu entry for openbox
  # @param config [yaml] menu entry to work with
  # @param ctx [OpenStruct] context to work with
  # @param k [OpenStruct] keys for mapping
  def add_menu_entry(config, ctx, k)
    menu_xml = "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
    menu_xml += "<openbox_menu xmlns=\"http://openbox.org/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://openbox.org/\">\n"
    menu_xml += '  <menu id="root-menu" label="Applications">'
    menu_xml += "    <separator label=\"--= #{'<%=distro=>'.erb(ctx.vars).upcase} =--\"/>"
    menu_xml += '    <separator/>'
    menu_xml += '    <separator/>'
    footer = "  </menu>\n</openbo_menu>"

    menu_path = File.join(ctx.root, 'etc/skel/.config/openbox/menu.xml')
    puts("Adding menu entry: #{config[k.label]}")

    # Quick launch
    #---------------------------------------------------------------------------
    menu_xml += quick_launch

    # Application menus
    #---------------------------------------------------------------------------

    # Session controls
    #---------------------------------------------------------------------------
    menu_xml += session
  end

  # Redirect paths according to the given contex
  # @param config [yaml] to redirect paths for
  # @param ctx [OpenStruct] context to work with
  # @param k [OpenStruct] keys for mapping
  # @returns [String] redirected string
  def redirect(config, ctx, k)
    all = [config[k.edit], config[k.resolve], config[k.exec]].compact
    raise ArgumentError.new("Invalid config type") if not all.any?
    return config if all.any?{|x| x.include?(ctx.root)}
    _config = config.clone

    # Handle edits and resolves
    if (file = _config[k.edit] || _config[k.resolve])
      raise ArgumentError.new("Paths must be absolute") if not file.start_with?('/')
      file = file.start_with?('//') ? file[1..-1] : File.join(ctx.root, file)
      _config[k.edit] = file if _config[k.edit]
      _config[k.resolve] = file if _config[k.resolve]

    # Handle bash scripts
    elsif _config[k.exec]
      _config[k.exec].gsub!(/ \/([^\/])/, ' ' + ctx.root + '/' + '\1')
      _config[k.exec].gsub!(/ \/\//, ' /')
    end

    return _config
  end
end

# vim: ft=ruby:ts=2:sw=2:sts=2
