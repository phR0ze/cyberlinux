#!/usr/bin/env ruby
require 'digest'
require 'fileutils'
require 'yaml'

require_relative 'erb'

module Fedit

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
        Digest::MD5.hexdigest(File.open(x, 'rb')) != digests[x]}
    else
      newfiles = files
    end

    return newfiles, modifiedfiles, deletedfiles
  end
  module_function(:digests_changed)

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
      digests[x] = Digest::MD5.hexdigest(File.read(x, 'rb')) if File.exist?(x)
    }

    # Write out digests structure as yaml with named header
    File.open(digestfile, 'w'){|f|
      f.puts({key => digests}.to_yaml)
    }
  end
  module_function(:update_digests)

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
  module_function(:replace)

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
  module_function(:insert)

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
  module_function(:resolve)
end

# vim: ft=ruby:ts=2:sw=2:sts=2
