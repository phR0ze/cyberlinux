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

require 'nub'
require 'yaml'
require 'minitest/autorun'

reduce_path = File.join(File.dirname(File.expand_path(__FILE__)), '../reduce')
load reduce_path

class Test_getimages < Minitest::Test

  def setup
    @base = {
      "vars" => {
        "arch" => "x86_64",
        "release" => "0.1.305",
        "distro" => "cyberlinux",
        "language" => "en_US",
        "character_set" => "UTF=8",
        "timezone" => "US/Mountain",
        "country" => "United_States",
        "color_light" => "#39AEF4",
        "color_dark" => "#215A94",
        "gfxmode" => "1280x1024",
        "grub_iso_theme" => "/boot/grub/themes/cyberlinux"
      },
      "defaults" => {
      },
      "builder" => {
        "type" => "container",
        "multilib" => true,
        "docker" => {
          "params" => '-e TERM=xterm -v /var/run/docker.sock:/var/run/docker.sock --privileged=true',
          "command" => 'bash -c "while :; do sleep 5; done"',
        },
        "apps" => [
          { "install" => "linux", "desc" => "Linux kernel and supporting modules" }
        ]
      },
      'deployments' => {
        'base' => {
          'multilib' => false,
          'apps' => [
            'base-apps',
          ]
        },
        'server' => {
          'multilib' => true,
          'vars' => {
            'timezone' => "Africa"
          },
          'apps' => [
            'server-apps',
            'server-configs'
          ]
        },
        'live' => {
        }
      },
      'apps' => {
        'base-apps' => [
          'conky',
          { 'install' => 'curl', 'desc' => 'Network download REST command line tool' },
          { 'install' => 'gcc-libs', 'desc' => 'GCC runtime libraries', 'multilib' => false },
          { 'install' => 'gcc-libs-multilib', 'desc' => 'GCC runtime libraries', 'multilib' => true }
        ],
        'server-apps' => [
          'base-apps',
          'phpBB'
        ],
        'conky' => [
          { 'install' => 'conky', 'desc' => 'Lightweight system monitor for X' },
          { 'exec' => 'echo 1 >> <%=country%>' }
        ],
        'phpBB' => [
          { 'install' => 'apache', 'desc' => 'Apache web server' }
        ]
      },
      "configs" => {
        "server-configs" => [
          {'chroot' => 'systemctl enable httpd.service'},
          {"edit" => "/etc/httpd/conf/httpd.conf", "regex" => '^(timezone).*', "value" => '<%=timezone%>'}
        ]
      }
    }

    @base_mock = Minitest::Mock.new
    @base_mock.expect(:[], true, ['vars'])
    @base_mock.expect(:[], @base['vars'], ['vars'])
    @base_mock.expect(:[], false, ['base'])
    ["defaults", "builder", "apps", "configs", "deployments"].each{|x|
      @base_mock.expect(:[], true, [x]); @base_mock.expect(:[], @base[x], [x])}

    YAML.stub(:load_file, @base_mock){
      @reduce = Reduce.new
      @k = @reduce.instance_variable_get(:@k)
      @vars = @reduce.instance_variable_get(:@vars)
      @type = @reduce.instance_variable_get(:@type)
      @profile = @reduce.instance_variable_get(:@profile)
    }
  end

  def teardown
    assert_mock(@base_mock)
  end

  def test_get_live_container_images
    images = "foo-0.2.1:2.5MB\nfoo-0.1.0:1.5MB\nbar:2.3MB\nfoo-0.3.1:3.4MB"
    @reduce.stub(:`, images){
      results = @reduce.getimages(@type.tgz, live:true)
      assert_equal([
        ["foo-0.3.1", "3.4MB"],
        ["foo-0.2.1", "2.5MB"],
        ["foo-0.1.0", "1.5MB"],
        ["bar", "2.3MB"],
      ], results)
    }
  end

  def test_get_live_container_images_for_deployment
    images = "foo-0.2.1:2.5MB\nfoo-0.1.0:1.5MB\nbar:2.3MB\nfoo-0.3.1:3.4MB"
    @reduce.stub(:puts, nil) {
      @reduce.stub(:`, images){
        results = @reduce.getimages(@type.tgz, live:true, deployment:"foo")
        assert_equal([
          ["foo-0.3.1", "3.4MB"],
          ["foo-0.2.1", "2.5MB"],
          ["foo-0.1.0", "1.5MB"],
        ], results)
      }
    }
  end

  def test_get_isos_and_boxes
    ['iso', 'box'].each{|type|
      image_path = "/bogus/path"
      images = [
        File.join(image_path, "will-be-removed.#{type}"),
        File.join(image_path, "#{@vars.distro}-foo-0.2.0.#{type}"),
        File.join(image_path, "#{@vars.distro}-foo-0.1.0.#{type}"),
        File.join(image_path, "#{@vars.distro}-bogus-0.1.0.#{type}"),
        File.join(image_path, "#{@vars.distro}-foo-0.3.1.#{type}")
      ]
      @reduce.instance_variable_set(:@imagepaths, [image_path])

      @reduce.stub(:puts, nil) {
        File.stub(:size, 111) {
          Dir.stub(:exist?, true) {
            Dir.stub(:[], images) {
              results = @reduce.getimages(type, deployment:"foo")
              assert_equal([
                [File.join(image_path, "#{@vars.distro}-foo-0.3.1.#{type}"), 111],
                [File.join(image_path, "#{@vars.distro}-foo-0.2.0.#{type}"), 111],
                [File.join(image_path, "#{@vars.distro}-foo-0.1.0.#{type}"), 111],
              ], results)
            }
          }
        }
      }
    }
  end

  def test_get_sqfs_and_imgs
    ['sqfs', 'img'].each{|type|
      image_path = "/bogus/path"
      images = [
        File.join(image_path, "will-be-removed.#{type}"),
        File.join(image_path, "foo.#{type}"),
        File.join(image_path, "bogus.#{type}"),
      ]
      @reduce.instance_variable_set(:@imagepaths, [image_path])

      @reduce.stub(:puts, nil) {
        File.stub(:size, 111) {
          Dir.stub(:exist?, true) {
            Dir.stub(:[], images) {
              results = @reduce.getimages(type, deployment:"foo")
              assert_equal([
                [File.join(image_path, "foo.#{type}"), 111],
              ], results)
            }
          }
        }
      }
    }
  end

  def test_deployment_image_not_found
    image_path = "/bogus/path"
    images = [File.join(image_path, "will-be-removed.iso")]
    @reduce.instance_variable_set(:@imagepaths, [image_path])

    File.stub(:size, 111) {
      Dir.stub(:exist?, true) {
        Dir.stub(:[], images) {
          Sys.capture{assert_raises(SystemExit){
            @reduce.getimages(@type.iso, deployment:"bar", die:true)}
          }
        }
      }
    }
  end
end
