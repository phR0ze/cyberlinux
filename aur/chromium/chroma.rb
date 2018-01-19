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

require 'fileutils'             # advanced file utils: FileUtils
require 'json'                  # JSON support
require 'open3'                 # Better exec
require 'ostruct'               # OpenStruct
require 'net/http'              # standard Ruby HTTP gem
require 'uri'                   # URI support

begin
  require 'utils'               # commands for command line params
  require 'colorize'            # color output: colorize
  require 'nokogiri'            # web scraping library
  require 'mechanize'           # web scraping library
rescue Exception => e
  mod = e.message.split(' ').last.sub('/', '-')
  !puts("Error: install missing package with 'sudo package -S ruby-#{mod}'") and exit
end

class Chroma
  def initialize
    @rootDir = File.dirname(File.expand_path(__FILE__))
    @patchesDir = File.join(@rootDir, 'patches')
    @extensionsDir = File.join(@rootDir, 'src', 'extensions')

    # Parse the PKGBUILD file for the chromium version
    @version = nil
    File.readlines(File.join(@rootDir, 'PKGBUILD')).each{|line|
        if ver = line[/^pkgver=(.*)$/, 1]
          @version = ver
          break
        end
    }

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
    @userAgentAlias = 'Mac Safari'

    @proxy = ENV['http_proxy']
    @proxyUri = @proxy ? @proxy.split(':')[1][2..-1] : nil
    @proxyPort = @proxy ? @proxy.split(':').last : nil

    # Extensions
    # --------------------------------------------------------------------------
    @extensions = {
      'https-everywhere' => 'gcbommkclmclpchllfjekcdonpmejbdp',     # Automatically use HTTPS security where possible
      'scriptsafe' => 'oiigbmnaadbkfbmpbfijlflahbdbdgdf',
      'smartup-gestures' => 'bgjfekefhjemchdeigphccilhncnjldn',     # Better mouse gestures for Chromium
      'tampermonkey' => 'dhdgffkkebhmkfjojejmpbldmpobfkfo',         # World's most popular userscript manager
      'ublock-origin' => 'cjpalhdlnbpafiamejdnhcphjbkeiagm',        # An efficient ad-blocker for Chromium
      'ublock-origin-extra' => 'pgdnlhfefecpicbbihgmbmffkjpaplco',  # Foil early hostile anti-user mechanisms
      'umatrix' => 'ogfcmafjalglgifnmanfmnieipoejdcf',
      'videodownload-helper' => 'lmjnegcaeklhafolokijcfjliaokphfk'  # Video download helper for Chromium
    }

    # Patch sets that are supported
    # --------------------------------------------------------------------------
    @patchSets = {
      @distros.arch => 'https://git.archlinux.org/svntogit/packages.git/tree/trunk?h=packages/chromium',
      @distros.debian => 'https://anonscm.debian.org/cgit/pkg-chromium/pkg-chromium.git/plain/debian/patches',
      @distros.inox => 'https://github.com/gcarq/inox-patchset',
      @distros.iridium => 'https://git.iridiumbrowser.de/cgit.cgi/iridium-browser/commit/?h=patchview'
    }

    # Call out patches used and not used and notes
    # Order is significant
    # --------------------------------------------------------------------------
    @usedPatches = {
      @distros.arch => [
        'breakpad-use-ucontext_t.patch',                # Glibc 2.26 does not expose struct ucontext any longer
        'chromium-gn-bootstrap-r17.patch',              #
      ],

      # Credit to Michael Gilber
      @distros.debian => [
        'manpage.patch',                                # Adds simple doc with link to documentation website

        'gn/parallel.patch',                            # Respect specified number of parllel jobs when bootstrapping
        'gn/narrowing.patch',                           # Silence narrowing warnings when bootstrapping gn
        'gn/buildflags.patch',                          # Support build flags passed in the --args to gn

        'disable/promo.patch',                          # Disable ad promo system by default
        'disable/fuzzers.patch',                        # Disable fuzzers as they aren't built anyway and only used for testing
        'disable/google-api-warning.patch',             # Disables Google's API key warning when they are removed from the PKGBUILD
        'disable/external-components.patch',            # Disable loading: Enhanced bookmarks, HotWord, ZipUnpacker, GoogleNow
        'disable/device-notifications.patch',           # Disable device discovery notifications

        'fixes/mojo.patch',                             # Fix mojo layout test build error
        'fixes/chromecast.patch',                       # Disable chromecast unless flag GOOGLE_CHROME_BUILD set
        'fixes/ps-print.patch',                         # Add postscript(ps) printing capabiliy
        'fixes/gpu-timeout.patch',                      # Increase GPU timeout from 10sec to 20sec
        'fixes/widevine-revision.patch',                # Set widevine version as undefined
        'fixes/connection-message.patch',               # Update connection message to suggest updating your proxy if you can't get connected.
        'fixes/chromedriver-revision.patch',            # Set as undefined, Chromedriver allows for automated testing of chromium
      ],

      @distros.cyber => [
        '00-master-preferences.patch',                  # Configure the master preferences to be in /etc/chromium/master_preferences
        '01-disable-default-extensions.patch',          # Apply on top of debian patches, disables cloud print and feedback
      ],

      # Credit to Michael Egger -> patches/inox/LICENSE
      # https://github.com/gcarq/inox-patchset
      #
      # Default Settings
      # ------------------------------------------------------------------------
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
        '0006-modify-default-prefs.patch',              # Set default settings as described in header
        '0007-disable-web-resource-service.patch',      #
        '0008-restore-classic-ntp.patch',               # The new NTP (New Tag Page) pulls from Google including tracking identifier
        '0009-disable-google-ipv6-probes.patch',        # Change IPv6 DNS probes to Google over to k.root-servers.net
        '0010-disable-gcm-status-check.patch',          # Disable Google Cloud-Messaging status probes, GCM allows direct msg to device
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
    # --------------------------------------------------------------------------
    @oneoffPatches = {
      @distros.arch => [
        'crc32c-string-view-check.patch',               #
      ],
    }

    # Not used patches
    # --------------------------------------------------------------------------
    @notUsedPatches = {
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
        '0004-disable-google-url-tracker.patch',        # No URL tracking (Google saves your location) also breaks omnibar search
        '0005-disable-default-extensions.patch',        # see above
        '0011-add-duckduckgo-search-engine.patch',      # Adds DuckDuckGo as default search engine, still changeable in settings
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
    patchSetDir = File.join(@patchesDir, patchset)
    !puts("Error: Patchset was not found!".colorize(:red)) and exit unless @patchSets[patchset]
    puts("Downloading patchset '#{patchset}'".colorize(:green))
    puts("PatchSet Dir: #{patchSetDir}".colorize(:cyan))
    FileUtils.rm_rf(patchSetDir) if File.exist?(patchSetDir)
    FileUtils.mkdir_p(patchSetDir)
    FileUtils.mkdir_p(File.join(patchSetDir, @k.notused))
    FileUtils.mkdir_p(File.join(patchSetDir, @k.oneoff))

    # Download patches via mechanize
    # Save as offline file: agent.get(@patchSets[patchset]).content
    # Read from offline file: page = agent.get("file:///.../test.html"))}")
    Mechanize.new{|agent|
      agent.set_proxy(@proxyUri, @proxyPort)
      agent.user_agent_alias = @userAgentAlias

      # Download arch patches
      #-------------------------------------------------------------------------
      if patchset == @distros.arch
        page = agent.get(@patchSets[patchset])
        patchLinks = page.links.select{|x| x.href =~ /packages\.git\/plain\/trunk\/.*\.patch/}.map{|x| x.href}
        patchLinks.each{|link|
          name = link[/plain\/trunk\/(.*\.patch)/, 1]
          download(agent, link, File.join(patchSetDir, name))
        }

      # Download debian patches
      #-------------------------------------------------------------------------
      elsif patchset == @distros.debian
        baseUrl = "https://anonscm.debian.org"
        page = agent.get(@patchSets[patchset])
        links = page.links.select{|x| x.href =~ /cgit\/pkg-chromium\/pkg-chromium.git\/plain\/debian\/patches\// }
        fileLinks = links.select{|x| x.href !~ /.*\/$/}
        dirLinks = links.reject{|x| fileLinks.include?(x)}

        # Download root files
        fileLinks.each{|x| download(agent, File.join(baseUrl, x.href), File.join(patchSetDir, x.text)) }

        # Gather patches from dir links
        dirLinks.each{|dirlink|
          url = File.join(baseUrl, dirlink.href)
          puts("Scraping patch dir: #{url}")
          FileUtils.mkdir_p(File.join(patchSetDir, dirlink.text))
          links = agent.get(url).links.select{|x| x.href =~ /#{dirlink.href}/}
          links.each{|x| download(agent, File.join(baseUrl, x.href), File.join(patchSetDir, dirlink.text, x.text)) }
        }

      # Download inox patches
      #-------------------------------------------------------------------------
      elsif patchset == @distros.inox
        baseurl = "https://raw.githubusercontent.com/gcarq/inox-patchset/#{$version}/"
        page = agent.get(@patchSets[patchset])
        patchLinks = page.links.select{|x| x.href =~ /inox-patchset\/blob\/master\/.*\.patch/}
        patchLinks.each{|x|
          name = x.text
          link = baseurl + name
          download(agent, link, File.join(patchSetDir, name))
        }

      # Download iridium patches
      #-------------------------------------------------------------------------
      elsif patchset == @distros.iridium
        page = agent.get(@patchSets[patchset])
        baseUrl = "https://git.iridiumbrowser.de"
        patchLinks = page.links.select{|x| x.href =~ /iridium-browser\/tree.*patchview&id=/ }
        patchLinks.each{|x|
          name = x.text
          link = "#{baseUrl}#{x.href.sub('/tree/', '/plain/')}"
          download(agent, link, File.join(patchSetDir, name))
        }
      end
    }
  end

  # Install the patches from supported distributions
  # @param patchset [String] patchset preset string to use
  def installPatches(patchset)
    patchSetDir = File.join(@patchesDir, patchset)
    puts("Instaling patchset '#{patchset}'".colorize(:green))
    puts("PatchSet Dir: #{patchSetDir}".colorize(:cyan))

    # Use static ordering and matching
    if patchset == @distros.arch || patchset == @distros.inox

      # Sort and rename oneoffs
      if @oneoffPatches[patchset]
        @oneoffPatches[patchset].each{|x|
          puts("Moving '#{x}' to '#{@k.oneoff}'")
          File.rename(File.join(patchSetDir, x), File.join(patchSetDir, @k.oneoff, x))
        }
      end

      # Sort and rename not-used
      if @notUsedPatches[patchset]
        @notUsedPatches[patchset].each{|x|
          puts("Moving '#{x}' to '#{@k.notused}'")
          File.rename(File.join(patchSetDir, x), File.join(patchSetDir, @k.notused, x))
        }
      end

      # Sort and rename used
      if @usedPatches[patchset]
        @usedPatches[patchset].each_with_index{|x, i|
          new_name = "#{i.to_s.rjust(2, '0')}-#{x}"
          puts("Renaming '#{x}' to '#{new_name}'")
          File.rename(File.join(patchSetDir, x), File.join(patchSetDir, new_name))
        }
      end

    # Order patches according to 'series' file
    elsif patchset == @distros.iridium or patchset == @distros.debian
      open(File.join(patchSetDir, 'series'), 'r'){|f|
        i = 0
        f.readlines.each{|x|
          name = x.strip
          next if name == ""
          count = i.to_s.rjust(2, "0")

          if patchset == @distros.debian
            oldName = File.join(patchSetDir, name)
            newName = @notUsedPatches[@distros.debian].include?(name) ? File.join(patchSetDir, @k.notused, "#{count}-#{name.sub('/', '-')}") :
              File.join(patchSetDir, "#{count}-#{name.sub('/', '-')}")
          else
            oldName = File.join(patchSetDir, name)
            newName = File.join(patchSetDir, "#{count}-#{name}")
          end

          # Order file
          puts("Ordering as #{newName}")
          File.rename(oldName, newName)
          i += 1
        }
      }
    end

    # Remove any directories that are not needed
    Dir[File.join(patchSetDir, '*')].each{|x|
      FileUtils.remove_dir(x) if File.directory?(x) and not (x.include?(@k.notused) || x.include?(@k.oneoff))
    }
  end

  # Download the given extension
  # @param ext [String] extension by name to download
  def downloadExtension(ext)
    puts("%s: %s" % ["Downloading".colorize(:light_yellow), "#{ext}".colorize(:cyan)])
    puts("  %s: %s" % ["Chromium".colorize(:light_yellow), "#{@version}".colorize(:cyan)])

    # Lookup the extension id
    extID = @extensions[ext]
    extPath = File.join(@extensionsDir, "#{ext}.crx")
    !puts("Error: No extension id for '#{ext}' was found!".colorize(:red)) and exit unless extID
    puts("  %s: %s" % ["Extension ID".colorize(:light_yellow), "#{extID}".colorize(:cyan)])
    puts("  %s: %s" % ["Extension Dest".colorize(:light_yellow), "#{extPath}".colorize(:cyan)])

    # Create extensions directory
    FileUtils.mkdir_p(@extensionsDir) if !File.exist?(@extensionsDir)

    # Construct request uri
    if !File.exist?(extPath)
      uri = URI.parse("https://clients2.google.com/service/update2/crx")
      uri.query = URI.encode_www_form({
        'response' => 'redirect',
        'os' => 'linux',
        'prodversion' => @version,
        'x' => "id=#{extID}&installsource=ondemand&uc"
      })
      puts("  %s: %s" % ["Request".colorize(:light_yellow), "#{uri}".colorize(:cyan)])

      # net/http call to stream down extension
      Net::HTTP.start(uri.host, nil, @proxyUri, @proxyPort){|http|
        res = http.request_head(uri) 
        extUri = URI.parse(res['location'])
        !puts("Error: extension is an unknown format!") and exit unless extUri.to_s.split('.').last == "crx"
        #puts(res.to_hash)

        # Stream download into local file
        http.request(Net::HTTP::Get.new(extUri)){|res|
          puts("  %s: %s" % ["URI".colorize(:light_yellow), "#{extUri}".colorize(:cyan)])
          puts("  %s: %s" % ["FILE".colorize(:light_yellow), "#{extPath}".colorize(:cyan)])
          print("  PROGRESS: ".colorize(:light_yellow))
          cnt = 0
          open(extPath, 'wb'){|f|
            res.read_body{|chunk|
              print('.') if (cnt += 1) % 2 == 0
              f << chunk
            }
          }
          puts("success!".colorize(:green))
        }
      }
    else
      puts("  %s: %s" % ["Extension Already Exists".colorize(:light_yellow), "#{extPath}".colorize(:cyan)])
    end

    # Generate the preferences file
    prefPath= File.join(@extensionsDir, "#{extID}.json")
    if !File.exist?(prefPath)

      # Unzip the extension
      tmpDir = File.join(@extensionsDir, '_tmp')
      FileUtils.rm_rf(tmpDir) if File.exist?(tmpDir)
      Open3.popen2e("unzip #{extPath} -d #{tmpDir}") {|i, o, t| t.value }

      # Generate the JSON preferences file
      manifest = File.join(tmpDir, 'manifest.json')
      json = JSON.parse(File.read(manifest))
      extVer = json['version']
      puts("  %s: %s" % ["Extension Ver".colorize(:light_yellow), "#{extVer}".colorize(:cyan)])
      pref = {
        "external_crx" => File.join("/usr/share/chromium/extensions", File.basename(ext)),
        "external_version" => extVer
      }
      puts("  %s: %s" % ["Creating Prefs".colorize(:light_yellow), "#{prefPath}".colorize(:cyan)])
      open(prefPath, 'w'){|f| f << JSON.pretty_generate(pref)}

      # Clean up
      FileUtils.rm_rf(tmpDir) if File.exist?(tmpDir)
    else
      puts("  %s: %s" % ["Preference File Already Exists".colorize(:light_yellow), "#{extPath}".colorize(:cyan)])
    end

    puts("Done".colorize(:light_yellow))
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
      agent.set_proxy(@proxyUri, @proxyPort)
      agent.user_agent_alias = @userAgentAlias
      page = agent.get("http://www.whoishostingthis.com/tools/user-agent/")
      puts(page.css('.info-box').first.content)
    }
  end

  # Accessor method for version
  def getChromiumVersion
    return @version
  end
end

#-------------------------------------------------------------------------------
# Main entry point
#-------------------------------------------------------------------------------
if __FILE__ == $0
  chroma = Chroma.new

  app = 'chroma'
  version = chroma.getChromiumVersion
  examples = "Examples:\n".colorize(:green)
  examples += "./#{app}.rb useragent\n".colorize(:green)
  examples += "1) ./#{app}.rb download install --patches=arch\n".colorize(:green)
  examples += "2) ./#{app}.rb download install --patches=debian\n".colorize(:green)
  examples += "3) ./#{app}.rb download install --patches=inox\n".colorize(:green)
  examples += "4) ./#{app}.rb download install --extension=https-everywhere\n".colorize(:green)

  cmds = Cmds.new(app, version, examples)
  cmds.add('download', 'Download patches from the given distribution', [
    CmdOpt.new('--patches=DISTRO', 'Distribution to download patches from', type:String),
    CmdOpt.new('--extension=EXTENSION', 'Extension to download from Google Market', type:String),
  ])
  cmds.add('install', 'Mark un-used, order and clean up paches', [
    CmdOpt.new('--patches=DISTRO', 'Distribution to install patches for', type:String),
    CmdOpt.new('--extension=EXTENSION', 'Extension to install from Google Market', type:String),
  ])
  cmds.add('useragent', 'Check the useragent being seen externally', [])
  cmds.parse!
  puts(cmds.banner)

  # Handle downloads
  #-----------------------------------------------------------------------------
  if cmds[:download]
    chroma.downloadPatches(cmds[:patches]) if cmds[:patches]
    chroma.downloadExtension(cmds[:extension]) if cmds[:extension]
  end

  # Handle installs
  #-----------------------------------------------------------------------------
  if cmds[:install]
    chroma.installPatches(cmds[:patches]) if cmds[:patches]
    chroma.installExtension(cmds[:extension]) if cmds[:extension]
  end 

  # Test user agent
  #-----------------------------------------------------------------------------
  if cmds[:useragent]
    chroma.getUserAgent
  end
end

# vim: ft=ruby:ts=2:sw=2:sts=2
