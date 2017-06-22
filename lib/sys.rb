#!/usr/bin/env ruby
require 'fileutils'         # advanced file utils: FileUtils

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
    if Gem.win_platform?
      FileUtils.rm_rf(path)
    else
        Sys.exec("rm -rf #{path}")
    end

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

end

# vim: ft=ruby:ts=2:sw=2:sts=2
