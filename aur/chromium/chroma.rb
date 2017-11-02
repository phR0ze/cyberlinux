#!/usr/bin/env ruby
##MIT License
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

#-------------------------------------------------------------------------------
# Chromium build tool
# 1. Download all iridium patches
# 2. Update current patches with new patches
#-------------------------------------------------------------------------------
require 'fileutils'             # advanced file utils: FileUtils
require 'json'                  # JSON support
require 'ostruct'               # OpenStruct
require 'net/http'              # standard Ruby HTTP gem
require 'uri'                   # URI support

# Gems that need to be installed
begin
  require 'cmds'                # commands for command line params
  require 'colorize'            # color output: colorize
  require 'nokogiri'            # web scraping library
  require 'mechanize'           # web scraping library
rescue Exception => e
  mod = e.message.split(' ').last.sub('/', '-')
  !puts("Error: install missing module with 'sudo gem install #{mod} --no-user-install'") and exit
end

class Chroma
  def initialize
    @distros = OpenStruct.new({
      debian: 'debian',
      iridium: 'iridium'
    })
    @user_agent_alias = 'Mac Safari'

    @proxy = ENV['http_proxy']
    @proxy_uri = @proxy ? @proxy.split(':')[1][2..-1] : nil
    @proxy_port = @proxy ? @proxy.split(':').last : nil

    # Patch sets that are supported
    @patchsets = {
      @distros.debian => 'https://anonscm.debian.org/cgit/pkg-chromium/pkg-chromium.git/plain/debian/patches',
      @distros.iridium => 'https://git.iridiumbrowser.de/cgit.cgi/iridium-browser/commit/?h=patchview'
    }

    # Call out patches that are not used and why
    @not_used = {
      @distros.debian => [
        'manpage.patch',                      # Don't need documentation
        'fixes/dma.patch',                    # patches/arch has a patch for this
        'fixes/ps-print.patch',               # I don't care about printing to PostScript
        'fixes/widevine-revision.patch',      # patches/arch has a patch for this
        'system/icu.patch',                   # ?
        'system/vpx.patch',                   # ?
        'system/event.patch',                 # ?
        'system/libxml.patch',                # ?
        'system/ffmpeg.patch'                 # patches/arch has a patch for this
      ]
    }
  end

  # Download the latest patches from supported distributions
  # @param patchset [String] patchset preset string to use
  # @param outdir [String] output parent path to download to
  def download_patches(patchset, outdir)
    !puts("Error: Patchset was not found!".colorize(:red)) and exit unless @patchsets[patchset]
    puts("PatchSet: #{patchset}".colorize(:green))
    puts("Output: #{outdir}".colorize(:cyan))
    puts("Request: #{@patchsets[patchset]}".colorize(:cyan))
    FileUtils.rm_rf(outdir) if File.exist?(outdir)
    FileUtils.mkdir_p(outdir)
    FileUtils.mkdir_p(File.join(outdir, 'not-used'))

    # Download patches via mechanize
    # Save as offline file: agent.get(@patchsets[patchset]).content
    # Read from offline file: page = agent.get("file:///.../test.html"))}")
    #---------------------------------------------------------------------------
    Mechanize.new{|agent|
      agent.set_proxy(@proxy_uri, @proxy_port)
      agent.user_agent_alias = @user_agent_alias

      # Download debian patches
      if patchset == @distros.debian
        baseUrl = "https://anonscm.debian.org"
        page = agent.get(@patchsets[patchset])
        links = page.links.select{|x| x.href =~ /cgit\/pkg-chromium\/pkg-chromium.git\/plain\/debian\/patches\// }
        fileLinks = links.select{|x| x.href !~ /.*\/$/}
        dirLinks = links.reject{|x| fileLinks.include?(x)}

        # Download root files
        fileLinks.each{|x| download(agent, File.join(baseUrl, x.href), File.join(outdir, x.text)) }

        # Gather patches from dir links
        dirLinks.each{|dirlink|
          url = File.join(baseUrl, dirlink.href)
          puts("Scraping patch dir: #{url}")
          FileUtils.mkdir_p(File.join(outdir, dirlink.text))
          links = agent.get(url).links.select{|x| x.href =~ /#{dirlink.href}/}
          links.each{|x| download(agent, File.join(baseUrl, x.href), File.join(outdir, dirlink.text, x.text)) }
        }

      # Download iridium patches
      elsif patchset == @distros.iridium
        page = agent.get(@patchsets[patchset])
        baseUrl = "https://git.iridiumbrowser.de"
        patchLinks = page.links.select{|x| x.href =~ /iridium-browser\/tree.*patchview&id=/ }
        patchLinks.each{|x|
          name = x.text
          link = "#{baseUrl}#{x.href.sub('/tree/', '/plain/')}"
          download(agent, link, File.join(outdir, name))
        }
      end
    }

#    # Name and order patches
#    #---------------------------------------------------------------------------
#    # Order patches according to 'series' file
#    if patchset == @distros.iridium or patchset == @distros.debian
#      open(File.join(outdir, 'series'), 'r'){|f|
#        i = 0
#        f.readlines.each{|x|
#          name = x.strip
#          next if name == ""
#          count = i.to_s.rjust(2, "0")
#
#          if patchset == @distros.debian
#            oldName = File.join(outdir, name)
#            newName = @not_used[@distros.debian].include?(name) ? File.join(outdir, 'not-used', "#{count}-#{name.sub('/', '-')}") :
#              File.join(outdir, "#{count}-#{name.sub('/', '-')}")
#          else
#            oldName = File.join(outdir, name)
#            newName = File.join(outdir, "#{count}-#{name}")
#          end
#
#          # Order file
#          puts("Ordering as #{newName}")
#          File.rename(oldName, newName)
#          i += 1
#        }
#      }
#    end
#
#    # Remove any directories that are not 'not-used'
#    Dir[File.join(outdir, '*')].each{|x|
#      FileUtils.remove_dir(x) if File.directory?(x) and not x.include?('not-used')
#    }
  end

  # Download the given url to the given filepath
  # @param agent [] mechanize agent to use
  # @param url [String] url of file to download
  # @param filepath [String] file path to save the download as
  def download(agent, url, filepath)
    puts("Downloading: #{url} => #{filepath}")

    # Introduce a randomness to avoid scrap detection
    sleep(rand(100..300)/1000.0)

    # Stream the file down to the given path
    open(filepath, 'w') {|f| f << agent.get(url).content}
  end

  # Hit an external site and retrieve what our user agent looks like
  # @returns [String] user agent
  def getUserAgent()
    Mechanize.new{|agent|
      agent.set_proxy(@proxy_uri, @proxy_port)
      agent.user_agent_alias = @user_agent_alias
      page = agent.get("http://www.whoishostingthis.com/tools/user-agent/")
      puts(page.css('.info-box').first.content)
    }
  end
  
end

#-------------------------------------------------------------------------------
# Main entry point
#-------------------------------------------------------------------------------
if __FILE__ == $0
  opts = {}
  app = 'chroma'
  version = '0.0.1'
  examples = "Examples:\n".colorize(:green)
  examples += "sudo ./#{app}.rb download --patches=debian --outdir=patches\n".colorize(:green)

  cmds = Cmds.new(app, version, examples)
  cmds.add('download', 'Download patches from the given distribution', [
    CmdOpt.new('--patches=DISTRO', 'Distribution to download patches from', type:String, required:true),
    CmdOpt.new('--outdir=OUTDIR', 'Destination parent directory for patches', type:String, required:true)
  ])
  cmds.parse!

  # Execute
  puts(cmds.banner)
  chroma = Chroma.new
  if cmds[:download]
    #chroma.download_patches(opts[:patches], opts[:outdir]) if opts[:patches]
  end
end

# vim: ft=ruby:ts=2:sw=2:sts=2
