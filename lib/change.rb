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

require 'fileutils'
require 'ostruct'

require_relative 'core'
require_relative 'fedit'

module Change

  # Get change keys
  # Params:
  # +returns+:: OpenStruct of all the string keys being used for changes
  def keys
    return OpenStruct.new({
      after: 'after',
      apply: 'apply',
      append: 'append',
      before: 'before',
      chroot: 'chroot',
      edit: 'edit',
      exec: 'exec',
      regex: 'regex',
      resolve: 'resolve',
      value: 'value',
      values: 'values'
    })
  end
  module_function(:keys)

  # Apply the given change
  # This is the only method that can directly deal with changes and is meant to be the entry point
  # for all changes. Other methods surfaced in this module are only exposed for simplicity.
  # +changes+:: list of yaml blocks describing the changes
  # +ctx+:: OpenStruct containing the following
  #   root: root directory of the filesystem being built
  #   vars: hash of variables for templating
  #   changes: re-usable change blocks in context
  # +returns+:: true on change
  def apply(changes, ctx)
    changed = false
    changes = [changes] if not changes.is_a?(Array)
    k = Change.keys
    changes.each{|change|

      # Recurse on change references
      if change[k.apply]
        puts("Applying '#{change[k.apply]}'")
        begin
          changed |= apply(ctx.changes[change[k.apply]], ctx)
        rescue
          puts("Failed to find the change referenced by '#{change[k.apply]}'")
          raise
        end

      # Apply the change
      else

        # Resolve templating in the actual change
        change = change.erb(ctx.vars)

        # Redirect paths as required
        change = Change.redirect(change, ctx, k) if not change[k.chroot]

        # Apply bash scripts
        if change[k.chroot]
          Sys.exec("arch-chroot #{ctx.root} #{change[k.chroot]}")

        # Apply file edits
        elsif change[k.edit]
          file = change[k.edit]
          puts("Editing: #{file}")
          values = change[k.value] ? [change[k.value]] : change[k.values]
          FileUtils.mkdir_p(File.dirname(file)) if not File.exist?(File.dirname(file))

          if not File.exist?(file)
            changed |= Fedit.insert(file, values)
          else
            append = change[k.append]

            # Check if the changes have already been made
            data = File.binread(file)
            already = values.all?{|y| data =~ Regexp.new(Regexp.quote(y))}

            # Regex replacements
            if not append
              changed |= Fedit.replace(file, change[k.regex], values.first)

            # File insert/appends
            elsif not already
              offset = append == true ? nil : append == k.after ? 1 : 0
              changed |= Fedit.insert(file, values, regex:change[k.regex], offset:offset)
            end
          end

        # Apply bash scripts
        elsif change[k.exec]
          Sys.exec(change[k.exec])

        # Resolve template
        elsif change[k.resolve]
          changed |= Fedit.resolve(change[k.resolve], ctx.vars)
        end
      end
    }

    return changed
  end
  module_function(:apply)

  # Redirect paths according to the given contex
  # Params:
  # +change+:: YAML block to redirect paths for
  # +ctx+:: OpenStruct context to work with
  # +k+:: OpenStruct of keys for mapping
  # +returns+:: redirected string
  def redirect(change, ctx, k)
    all = [change[k.edit], change[k.resolve], change[k.exec]].compact
    raise ArgumentError.new("Invalid change type") if not all.any?
    return change if all.any?{|x| x.include?(ctx.root)}
    _change = change.clone

    # Handle edits and resolves
    if (file = _change[k.edit] || _change[k.resolve])
      raise ArgumentError.new("Paths must be absolute") if not file.start_with?('/')
      file = file.start_with?('//') ? file[1..-1] : File.join(ctx.root, file)
      _change[k.edit] = file if _change[k.edit]
      _change[k.resolve] = file if _change[k.resolve]

    # Handle bash scripts
    elsif _change[k.exec]
      _change[k.exec].gsub!(/ \/([^\/])/, ' ' + ctx.root + '/' + '\1')
      _change[k.exec].gsub!(/ \/\//, ' /')
    end

    return _change
  end
  module_function(:redirect)
end

# vim: ft=ruby:ts=2:sw=2:sts=2
