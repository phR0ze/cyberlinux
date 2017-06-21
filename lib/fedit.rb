#!/usr/bin/env ruby
require 'digest'
require 'fileutils'

require_relative 'erb'

# Replace in file
# Params:
# +file+:: file to modify
# +regex+:: regular expression match on
# +value+:: regulare expression to replace with
# +returns+:: true on change
def file_replace(file, regex, value)
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
# +offset+:: offset the insert location by this amount
# +returns+:: true if a change was made to the file
def file_insert(file, values, regex:nil, offset:1)
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
      i = regex ? lines.index{|x| x =~ regex} : lines.size - 1
      return false if not i
      i += offset

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
def resolve_template(file, vars)
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

# vim: ft=ruby:ts=2:sw=2:sts=2
