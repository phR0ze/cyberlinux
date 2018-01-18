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

require 'digest'
require 'fileutils'
require 'yaml'

require_relative 'core'

module Fedit
  extend self

  # Check if any digests have changed based on the given files
  # Params:
  # +key+:: yalm section heading to give digests
  # +digestfile+:: digest file to check against
  # +files+:: files to get digests for
  # +returns+:: (newfiles, modifiedfiles, deletedfiles)
  def digests_changed(key, digestfile, files)
    files = [files] if files.is_a?(String)
    newfiles, modifiedfiles, deletedfiles = [], [], []

    # Since layers are stacked and the digest file may be from a lower
    # layer this should be ignored unless the layer matches
    if (digests = File.exist?(digestfile) ? YAML.load_file(digestfile)[key] : nil)

      # New files: in files but not yaml
      newfiles = files.select{|x| not digests[x]}

      # Delete files: in yaml but not files
      deletedfiles = digests.map{|k,v| k}.select{|x| not files.include?(x)}

      # Modified files: in both but digest is different
      modifiedfiles = files.select{|x| digests[x] and
        Digest::MD5.hexdigest(File.binread(x)) != digests[x]}
    else
      newfiles = files
    end

    return newfiles, modifiedfiles, deletedfiles
  end

  # Generate digests for array of files given and save them
  # Params:
  # +key+:: yalm section heading to give digests
  # +digestfile+:: digest file to update
  # +files+:: files to get digests for
  def update_digests(key, digestfile, files)
    files = [files] if files.is_a?(String)

    # Build up digests structure
    digests = {}
    files.each{|x|
      digests[x] = Digest::MD5.hexdigest(File.binread(x)) if File.exist?(x)
    }

    # Write out digests structure as yaml with named header
    File.open(digestfile, 'w'){|f|
      f.puts({key => digests}.to_yaml)
    }
  end

  # Replace in file
  # Params:
  # +file+:: file to modify
  # +regex+:: regular expression match on
  # +value+:: regular expression string replacement
  # +returns+:: true on change
  def replace(file, regex, value)
    changed = false
    begin
      data = nil
      File.open(file, 'r+') do |f|
        data = f.read
        lines = data.split("\n")

        # Search replace
        regex = Regexp.new(regex) if regex.is_a?(String)
        lines.each{|x| x.gsub!(regex, value)}
        lines.each{|x| x.gsub!(/\r\n/, "\n")}

        # Determine if file changed
        changed = Digest::MD5.hexdigest(data) != Digest::MD5.hexdigest(lines * "\n")

        # Truncate then write out new content
        f.seek(0)
        f.truncate(0)
        f.puts(lines)
      end
    rescue
      # Revert back to the original incase of failure
      File.open(file, 'w'){|f| f << data} if data
      raise
    end

    return changed
  end

  # Insert into a file
  # Location of insert is determined by the given regex and offset.
  # Append is used if no regex is given.
  # Params:
  # +file+:: path of file to modify
  # +values+:: string or list of string values to insert
  # +regex+:: regular expression for location, not used if offset is nil
  # +offset+:: offset insert location by this amount for regexs
  # +returns+:: true if a change was made to the file
  def insert(file, values, regex:nil, offset:1)
    return false if not values or values.empty?

    changed = false
    values = [values] if values.is_a?(String)
    FileUtils.touch(file) if not File.exist?(file)

    begin
      data = nil
      File.open(file, 'r+') do |f|
        data = f.read
        lines = data.split("\n")

        # Match regex for insert location
        regex = Regexp.new(regex) if regex.is_a?(String)
        i = regex ? lines.index{|x| x =~ regex} : lines.size
        return false if not i
        i += offset if regex and offset

        # Insert at offset
        values.each{|x|
          lines.insert(i, x) and i += 1
          changed = true
        }

        # Truncate then write out new content
        f.seek(0)
        f.truncate(0)
        f.puts(lines)
      end
    rescue
      # Revert back to the original incase of failure
      File.open(file, 'w'){|f| f << data} if data
      raise
    end

    return changed
  end

  # Resolve template
  # Params:
  # +file+:: file to resolve templates for
  # +vars+:: hash or ostruct templating variables to use while resolving
  # +returns+:: true on change
  def resolve(file, vars)
    changed = false

    begin
      data = nil
      File.open(file, 'r+') do |f|
        data = f.read

        # Resolve templates
        _data = data.erb(vars)

        # Determine if file changed
        changed = Digest::MD5.hexdigest(data) != Digest::MD5.hexdigest(_data)

        # Truncate then write out new content
        if changed
          f.seek(0)
          f.truncate(0)
          f.puts(_data)
        end
      end
    rescue
      # Revert back to the original incase of failure
      File.open(file, 'w'){|f| f << data} if data
      raise
    end

    return changed
  end
end

# vim: ft=ruby:ts=2:sw=2:sts=2
