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

require 'yaml'
require 'minitest/autorun'

reduce_path = File.join(File.dirname(File.expand_path(__FILE__)), '../reduce')
load reduce_path

class Test_installapps < Minitest::Test

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
      "build" => {
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
        'dep1' => {
          'apps' => [
            'base-apps',
          ]
        },
        'dep2' => {
          'apps' => [
            'server-apps',
          ]
        }
      },
      'apps' => {
        'base-apps' => [
          'conky',
          { 'install' => 'curl', 'conflict' => 'curl2' },
          { 'install' => 'foo2', 'ignore' => true }
        ],
        'server-apps' => [
          'base-apps',
          'phpBB',
          { 'chroot' => 'systemctl enable httpd.service' }
        ],
        'conky' => [
          { 'install' => 'conky' },
          { 'exec' => 'echo 1 >> foobar' }
        ],
        'phpBB' => [
          { 'install' => 'apache', 'desc' => 'Apache web server' }
        ]
      },
      "configs" => {
        "server-configs" => [
          {"edit" => "/etc/httpd/conf/httpd.conf", "regex" => '^(Listen).*', "value" => '\1 80'}
        ]
      }
    }

    @base_mock = Minitest::Mock.new
    @base_mock.expect(:[], true, ['vars'])
    @base_mock.expect(:[], @base['vars'], ['vars'])
    @base_mock.expect(:[], false, ['base'])
    @base_mock.expect(:[], true, ['build'])
    @base_mock.expect(:[], @base['build'], ['build'])
    @base_mock.expect(:[], true, ['apps'])
    @base_mock.expect(:[], @base['apps'], ['apps'])
    @base_mock.expect(:[], true, ['configs'])
    @base_mock.expect(:[], @base['configs'], ['configs'])
    @base_mock.expect(:[], true, ['deployments'])
    @base_mock.expect(:[], @base['deployments'], ['deployments'])

    YAML.stub(:load_file, @base_mock){
      @reduce = Reduce.new
      @k = @reduce.instance_variable_get(:@k)
      @profile = @reduce.instance_variable_get(:@profile)
    }
  end

  def test_installapps_fresh
    mock = Minitest::Mock.new
    mock.expect(:readlines, ['curl', 'CONFLICT:curl2'])
    mock.expect(:puts, nil){|x| true}

    validate_cmd = -> (cmd, env:nil){
      #print(cmd)
      if cmd.is_a?(Array)
        assert_equal(7, cmd.size)
        assert(cmd.include?('conky'))
        assert(!cmd.include?('foo2'))
      end
      true
    }

    File.stub(:exist?, true){
      File.stub(:open, true, mock){
        Dir.stub(:[], []){
          Sys.stub(:exec, validate_cmd){
            Sys.stub(:umount, nil){
              @reduce.stub(:puts, nil){
                @reduce.stub(:rm_rf, nil){
                  @reduce.installapps('dep1', 'dep1.sqfs', '.', @base[@k.deployments]['dep1'])
                }
              }
            }
          }
        }
      }
    }
  end
end

# vim: ft=ruby:ts=2:sw=2:sts=2
