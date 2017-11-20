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

$version = '62.0.3202.94'

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
  # Initialize
  # @param outdir [String] output parent path to download to
  def initialize(outdir)
    @outdir = outdir || File.join(File.dirname(File.expand_path(__FILE__)), 'patches')
    @k = OpenStruct.new({
      oneoff: 'one-off',
      notused: 'not-used'
    })

    @distros = OpenStruct.new({
      arch: 'arch',
      cyber: 'cyber',
      inox: 'inox',
      debian: 'debian',
      iridium: 'iridium'
    })
    @user_agent_alias = 'Mac Safari'

    @proxy = ENV['http_proxy']
    @proxy_uri = @proxy ? @proxy.split(':')[1][2..-1] : nil
    @proxy_port = @proxy ? @proxy.split(':').last : nil

    # Patch sets that are supported
    @patchsets = {
      @distros.arch => 'https://git.archlinux.org/svntogit/packages.git/tree/trunk?h=packages/chromium',
      @distros.debian => 'https://anonscm.debian.org/cgit/pkg-chromium/pkg-chromium.git/plain/debian/patches',
      @distros.inox => 'https://github.com/gcarq/inox-patchset',
      @distros.iridium => 'https://git.iridiumbrowser.de/cgit.cgi/iridium-browser/commit/?h=patchview'
    }

    # Call out patches used and not used and notes
    # Order is significant
    @used_patches = {
      @distros.arch => [
        'breakpad-use-ucontext_t.patch',      # Glibc 2.26 does not expose struct ucontext any longer
        'chromium-gn-bootstrap-r17.patch',    #
      ],
      @distros.cyber => [
        'master-preferences.patch',           # Configure the master preferences to be in /etc/chromium/master_preferences
      ],

      # Credit to Michael Gilber
      @distros.debian => [
        'manpage.patch',                      # Adds simple doc with link to documentation website

        'gn/parallel.patch',                  # Respect specified number of parllel jobs when bootstrapping
        'gn/narrowing.patch',                 # Silence narrowing warnings when bootstrapping gn
        'gn/buildflags.patch',                # Support build flags passed in the --args to gn

        'disable/promo.patch',                # Disable ad promo system by default
        'disable/fuzzers.patch',              # Disable fuzzers as they aren't built anyway and only used for testing
        'disable/google-api-warning.patch',   # Disables Google's API key warning when they are removed from the PKGBUILD
        'disable/external-components.patch',  # Disable loading: Enhanced bookmarks, HotWord, ZipUnpacker, GoogleNow
        'disable/device-notifications.patch', # Disable device discovery notifications

        'fixes/mojo.patch',                   # Fix mojo layout test build error
        'fixes/chromecast.patch',             # Disable chromecast unless flag GOOGLE_CHROME_BUILD set
        'fixes/ps-print.patch',               # Add postscript(ps) printing capabiliy
        'fixes/gpu-timeout.patch',            # Increase GPU timeout from 10sec to 20sec
        'fixes/widevine-revision.patch',      # Set widevine version as undefined
        'fixes/connection-message.patch',     # Update connection message to suggest updating your proxy if you can't get connected.
        'fixes/chromedriver-revision.patch',  # Set as undefined, Chromedriver allows for automated testing of chromium
      ],

      # Credit to Michael Egger -> patches/inox/LICENSE
      # https://github.com/gcarq/inox-patchset
      #
      # Default Settings
      # ------------------------------------------------------------------------------------
      # DefaultCookiesSettings                            CONTENT_SETTING_DEFAULT
      # EnableHyperLinkAuditing 	                        false
      # CloudPrintSubmitEnabled 	                        false
      # NetworkPredictionEnabled 	                        false
      # BackgroundModeEnabled 	                          false
      # BlockThirdPartyCookies 	                          true
      # AlternateErrorPagesEnabled 	                      false
      # SearchSuggestEnabled 	                            false
      # AutofillEnabled 	                                false
      # Send feedback to Google if preferences are reset 	false
      # BuiltInDnsClientEnabled                         	false
      # SignInPromoUserSkipped 	                          true
      # SignInPromoShowOnFirstRunAllowed 	                false
      # ShowAppsShortcutInBookmarkBar 	                  false
      # ShowBookmarkBar 	                                true
      # PromptForDownload 	                              true
      # SafeBrowsingEnabled 	                            false
      # EnableTranslate 	                                false
      # LocalDiscoveryNotificationsEnabled 	              false
      @distros.inox => [
        '0001-fix-building-without-safebrowsing.patch', # Required when the PGKBUILD has safebrowing disabled
        '0003-disable-autofill-download-manager.patch', # Disables HTML AutoFill data transmission to Google
        '0004-disable-google-url-tracker.patch',        # Disable URL tracking which transmits your location to Google
        '0006-modify-default-prefs.patch',              # Set default settings as described in header
        '0007-disable-web-resource-service.patch',      #
        '0008-restore-classic-ntp.patch',               # The new NTP (New Tag Page) pulls from Google including tracking identifier
        '0009-disable-google-ipv6-probes.patch',        # Change IPv6 DNS probes to Google over to k.root-servers.net
        '0010-disable-gcm-status-check.patch',          # Disable Google Cloud-Messaging status probes, GCM allows direct msg to device
        '0011-add-duckduckgo-search-engine.patch',      # Adds DuckDuckGo as default search engine, still changeable in settings
        '0014-disable-translation-lang-fetch.patch',    # Disable language fetching from Google when settings are opened the first time
        '0015-disable-update-pings.patch',              # Disable update pings to Google
        '0016-chromium-sandbox-pie.patch',              # Hardening sandbox with Position Independent code, originally from openSUSE
        '0017-disable-new-avatar-menu.patch',           # Disable Google Avatar signin menu
        '0018-disable-first-run-behaviour.patch',       # Modifies first run to prevent data leakage
        '0019-disable-battery-status-service.patch',    # Disable battry status service as it can be used for tracking
        '0021-disable-rlz.patch',                       # Disable RLZ
        '9000-disable-metrics.patch',                   # Disable metrics
        '9001-disable-profiler.patch',                  # Disable profiler
      ]
    }

    # Patches handled in PKGBUILD differently
    @oneoff_patches = {
      @distros.arch => [
        'crc32c-string-view-check.patch',               #
      ],
    }

    @not_used_patches = {
      @distros.arch => [
        'chromium-widevine.patch',                      # Using debian as this one uses a variable
      ],
      @distros.debian => [
        'master-preferences.patch',                     # Use custom cyber patch instead
        'disable/third-party-cookies.patch',            # Already covered in inox/0006-modify-default-prefs'
        'gn/bootstrap.patch',                           # Fix errors in gn's bootstrapping script, using arch bootstrap instead
        'fixes/crc32.patch',                            # Fix inverted check, using arch crc32c-string-view-check.patch instead
        'system/nspr.patch',                            # Build using the system nspr library
        'system/icu.patch',                             # Backwards compatibility for older versions of icu
        'system/vpx.patch',                             # Remove VP9 support because debian libvpx doesn't support VP9 yet
        'system/gtk2.patch',                            # 
        'system/lcms2.patch',                           # 
        'system/event.patch',                           # Build using the system libevent library
      ],
      @distros.inox => [
        # Disables Hotword, Google Now/Feedback/Webstore/Hangout, Cloud Print, Speech synthesis
        # I like keeping the Webstore and Hangout features so will roll my own patch in cyberlinux
        '0005-disable-default-extensions.patch',        # see above
        '0012-branding.patch',                          # Want to keep the original Chromium branding
        '0013-disable-missing-key-warning.patch',       # Disables warning, using debian patch instead
        '0020-launcher-branding.patch',                 # Want to keep the original Chromium branding
        'breakpad-use-ucontext_t.patch',                # Already included by Arch Linux
        'chromium-gn-bootstrap-r17.patch',              # Already included by Arch Linux
        'chromium-widevine.patch',                      # Already included by Arch Linux
        'crc32c-string-view-check.patch',               # Already included by Arch Linux
        'chromium-libva-version.patch',                 # Arch doesn't use it
        'chromium-vaapi-r14.patch',                     # Arch doesn't use it
      ]
    }
  end

  # Download the latest patches from supported distributions
  # @param patchset [String] patchset preset string to use
  def downloadPatches(patchset)
    patchset_dir = File.join(@outdir, patchset)
    !puts("Error: Patchset was not found!".colorize(:red)) and exit unless @patchsets[patchset]
    puts("Downloading patchset '#{patchset}'".colorize(:green))
    puts("PatchSet Dir: #{patchset_dir}".colorize(:cyan))
    FileUtils.rm_rf(patchset_dir) if File.exist?(patchset_dir)
    FileUtils.mkdir_p(patchset_dir)
    FileUtils.mkdir_p(File.join(patchset_dir, @k.notused))
    FileUtils.mkdir_p(File.join(patchset_dir, @k.oneoff))

    # Download patches via mechanize
    # Save as offline file: agent.get(@patchsets[patchset]).content
    # Read from offline file: page = agent.get("file:///.../test.html"))}")
    Mechanize.new{|agent|
      agent.set_proxy(@proxy_uri, @proxy_port)
      agent.user_agent_alias = @user_agent_alias

      # Download arch patches
      #-------------------------------------------------------------------------
      if patchset == @distros.arch
        page = agent.get(@patchsets[patchset])
        patchLinks = page.links.select{|x| x.href =~ /packages\.git\/plain\/trunk\/.*\.patch/}.map{|x| x.href}
        patchLinks.each{|link|
          name = link[/plain\/trunk\/(.*\.patch)/, 1]
          download(agent, link, File.join(patchset_dir, name))
        }

      # Download debian patches
      #-------------------------------------------------------------------------
      elsif patchset == @distros.debian
        baseUrl = "https://anonscm.debian.org"
        page = agent.get(@patchsets[patchset])
        links = page.links.select{|x| x.href =~ /cgit\/pkg-chromium\/pkg-chromium.git\/plain\/debian\/patches\// }
        fileLinks = links.select{|x| x.href !~ /.*\/$/}
        dirLinks = links.reject{|x| fileLinks.include?(x)}

        # Download root files
        fileLinks.each{|x| download(agent, File.join(baseUrl, x.href), File.join(patchset_dir, x.text)) }

        # Gather patches from dir links
        dirLinks.each{|dirlink|
          url = File.join(baseUrl, dirlink.href)
          puts("Scraping patch dir: #{url}")
          FileUtils.mkdir_p(File.join(patchset_dir, dirlink.text))
          links = agent.get(url).links.select{|x| x.href =~ /#{dirlink.href}/}
          links.each{|x| download(agent, File.join(baseUrl, x.href), File.join(patchset_dir, dirlink.text, x.text)) }
        }

      # Download inox patches
      #-------------------------------------------------------------------------
      elsif patchset == @distros.inox
        baseurl = "https://raw.githubusercontent.com/gcarq/inox-patchset/#{$version}/"
        page = agent.get(@patchsets[patchset])
        patchLinks = page.links.select{|x| x.href =~ /inox-patchset\/blob\/master\/.*\.patch/}
        patchLinks.each{|x|
          name = x.text
          link = baseurl + name
          download(agent, link, File.join(patchset_dir, name))
        }

      # Download iridium patches
      #-------------------------------------------------------------------------
      elsif patchset == @distros.iridium
        page = agent.get(@patchsets[patchset])
        baseUrl = "https://git.iridiumbrowser.de"
        patchLinks = page.links.select{|x| x.href =~ /iridium-browser\/tree.*patchview&id=/ }
        patchLinks.each{|x|
          name = x.text
          link = "#{baseUrl}#{x.href.sub('/tree/', '/plain/')}"
          download(agent, link, File.join(patchset_dir, name))
        }
      end
    }
  end

  # Process the patches from supported distributions
  # @param patchset [String] patchset preset string to use
  def processPatches(patchset)
    patchset_dir = File.join(@outdir, patchset)
    puts("Processing patchset '#{patchset}'".colorize(:green))
    puts("PatchSet Dir: #{patchset_dir}".colorize(:cyan))

    # Use static ordering and matching
    if patchset == @distros.arch || patchset == @distros.inox

      # Sort and rename oneoffs
      if @oneoff_patches[patchset]
        @oneoff_patches[patchset].each{|x|
          puts("Moving '#{x}' to '#{@k.oneoff}'")
          File.rename(File.join(patchset_dir, x), File.join(patchset_dir, @k.oneoff, x))
        }
      end

      # Sort and rename not-used
      if @not_used_patches[patchset]
        @not_used_patches[patchset].each{|x|
          puts("Moving '#{x}' to '#{@k.notused}'")
          File.rename(File.join(patchset_dir, x), File.join(patchset_dir, @k.notused, x))
        }
      end

      # Sort and rename used
      if @used_patches[patchset]
        @used_patches[patchset].each_with_index{|x, i|
          new_name = "#{i.to_s.rjust(2, '0')}-#{x}"
          puts("Renaming '#{x}' to '#{new_name}'")
          File.rename(File.join(patchset_dir, x), File.join(patchset_dir, new_name))
        }
      end

    # Order patches according to 'series' file
    elsif patchset == @distros.iridium or patchset == @distros.debian
      open(File.join(patchset_dir, 'series'), 'r'){|f|
        i = 0
        f.readlines.each{|x|
          name = x.strip
          next if name == ""
          count = i.to_s.rjust(2, "0")

          if patchset == @distros.debian
            oldName = File.join(patchset_dir, name)
            newName = @not_used_patches[@distros.debian].include?(name) ? File.join(patchset_dir, @k.notused, "#{count}-#{name.sub('/', '-')}") :
              File.join(patchset_dir, "#{count}-#{name.sub('/', '-')}")
          else
            oldName = File.join(patchset_dir, name)
            newName = File.join(patchset_dir, "#{count}-#{name}")
          end

          # Order file
          puts("Ordering as #{newName}")
          File.rename(oldName, newName)
          i += 1
        }
      }
    end

    # Remove any directories that are not needed
    Dir[File.join(patchset_dir, '*')].each{|x|
      FileUtils.remove_dir(x) if File.directory?(x) and not (x.include?(@k.notused) || x.include?(@k.oneoff))
    }
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
  def getUserAgent
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
  examples = "Examples:\n".colorize(:green)
  examples += "./#{app}.rb useragent\n".colorize(:green)
  examples += "1) ./#{app}.rb download process --patches=arch\n".colorize(:green)
  examples += "2) ./#{app}.rb download process --patches=debian\n".colorize(:green)
  examples += "2) ./#{app}.rb download process --patches=inox\n".colorize(:green)

  cmds = Cmds.new(app, $version, examples)
  cmds.add('download', 'Download patches from the given distribution', [
    CmdOpt.new('--patches=DISTRO', 'Distribution to download patches from', type:String, required:true),
    CmdOpt.new('--outdir=OUTDIR', 'Destination parent directory for patches', type:String)
  ])
  cmds.add('process', 'Mark un-used, order and clean up paches', [
    CmdOpt.new('--patches=DISTRO', 'Distribution to process patches for', type:String, required:true),
    CmdOpt.new('--outdir=OUTDIR', 'Destination parent directory for patches', type:String)
  ])
  cmds.add('useragent', 'Check the useragent being seen externally', [])
  cmds.parse!

  # Execute
  puts(cmds.banner)
  chroma = Chroma.new(cmds[:outdir])

  if cmds[:download]
    chroma.downloadPatches(cmds[:patches])
  end

  if cmds[:process]
    chroma.processPatches(cmds[:patches])
  end 

  if cmds[:useragent]
    chroma.getUserAgent
  end
end

# vim: ft=ruby:ts=2:sw=2:sts=2
