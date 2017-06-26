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

begin
  require 'colorize'        # color output: colorize
rescue Exception => e
  gem = e.message.split(' ').last.sub('/', '-')
  !puts("Error: install missing gem with 'sudo gem install --no-user-install #{gem}'") and exit
end

module Sys

  # Run the system command in an exception wrapper
  # Params:
  # +cmd+:: cmd to execute
  # +env+:: optional environment variables to set
  # +die+:: fail on errors if true
  # +returns+:: true on success else false
  def exec(cmd, env:{}, die:true)
    result = false
    puts("exec: #{cmd.is_a?(String) ? cmd : cmd * ' '}")

    begin
      if cmd.is_a?(String)
        result = system(env, cmd, out: $stdout, err: :out)
      else
        result = system(env, *cmd, out: $stdout, err: :out)
      end
    rescue Exception => e
      result = false
      puts(e.message.colorize(:red))
      puts(e.backtrace.inspect.colorize(:red))
      exit if die
    end

    !puts("Error: failed to execute command properly".colorize(:red)) and
      exit unless !die or result

    return result
  end
  module_function(:exec)

  # Remove given dir or file
  # Params:
  # +path+:: path to delete
  # +returns+:: path that was deleted
  def rm_rf(path)
    Sys.exec("rm -rf #{path}")
    return path
  end
  module_function(:rm_rf)

  # Unmount the given mount point
  # Params:
  # +mount+:: mount point to unmount
  # +retries+:: number of times to retry
  def umount(mount, retries:1)
    check = ->(mnt){
      match = `mount`.split("\n").find{|x| x.include?(mnt)}
      match = match.split('overlay').first if match
      return (match and match.include?(mnt))
    }

    success = false
    while not success and retries > 0
      if check[mount]
        success = system('umount', '-fv', mount)
      else
        success = true
      end

      # Sleep for a second if failed
      sleep(1) and retries -= 1 unless success
    end

    # Die if still mounted
    !puts("Error: Failed to umount #{mount}".colorize(:red)) and
      exit if check[mount]
  end
  module_function(:umount)

  # Drop root privileges to original user
  # Only affects ruby commands not system commands
  # Params:
  # +returns+:: uid, gid of prior user
  def drop_privileges()
    uid = gid = nil

    if Process.uid.zero?
      uid, gid = Process.uid, Process.gid
      sudo_uid, sudo_gid = ENV['SUDO_UID'].to_i, ENV['SUDO_GID'].to_i
      Process::Sys.setegid(sudo_uid)
      Process::Sys.seteuid(sudo_gid)
    end

    return uid, gid
  end
  module_function(:drop_privileges)

  # Raise privileges if dropped earlier
  # Only affects ruby commands not system commands
  # Params:
  # +uid+:: uid of user to assume
  # +gid+:: gid of user to assume
  def raise_privileges(uid, gid)
    if uid and gid
      Process::Sys.seteuid(uid)
      Process::Sys.setegid(gid)
    end
  end
  module_function(:raise_privileges)

  # Capture stdout for the block given
  # +block+:: block of code to execute
  # +returns+:: string of the captured stdout
  def capture(&block)

    begin
      # Capture output
      stdout, stderr = StringIO.new, StringIO.new
      $stdout, $stderr = stdout, stderr

      # Invoke block
      result = block.call

    # Restore normal operation
    ensure
      $stdout, $stderr = STDOUT, STDERR
    end

    # Return results
    OpenStruct.new(result: result, stdout: stdout.string, stderr: stderr.string)
  end
  module_function(:capture)
end

# vim: ft=ruby:ts=2:sw=2:sts=2
