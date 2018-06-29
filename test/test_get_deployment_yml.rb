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

class Test_get_deployment_yml < Minitest::Test

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
      "deployments" => {
        "dep1" => {
          "type" => "machine",
          "apps" => ["server-apps"]
        },
        "dep2" => {
          "base" => "dep1",
          "type" => "machine",
          "vars" => {
            "timezone" => "Africa"
          },
          "apps" => [
            {"edit" => "/etc/httpd/conf/httpd.conf", "regex" => 'timezone', "value" => '<%=timezone%>'}
          ]
        }
      },
      "apps" => {
        "server-apps" => ["conky", "config-server"],
        "conky" => [
          { "install" => "conky", "desc" => "Lightweight system monitor for X" }
        ]
      },
      "configs" => {
        "config-server" => [
          {"edit" => "/etc/httpd/conf/httpd.conf", "regex" => 'timezone', "value" => '<%=timezone%>'}
        ]
      }
    }

    @base_mock = Minitest::Mock.new
    @base_mock.expect(:[], true, ['vars'])
    @base_mock.expect(:[], @base['vars'], ['vars'])
    @base_mock.expect(:[], false, ['base'])
    ["defaults", "builder", "apps", "configs", "deployments"].each{|x|
      @base_mock.expect(:[], true, [x]); @base_mock.expect(:[], @base[x], [x])}

    Log.init(path:nil, queue: true, stdout: false)
    YAML.stub(:load_file, @base_mock){
      @reduce = Reduce.new
      @k = @reduce.instance_variable_get(:@k)
      @profile = @reduce.instance_variable_get(:@profile)
    }

    @source_path = File.expand_path(File.join(File.dirname(__FILE__), '../source'))
    @base['builder']['source'] = [File.join(@source_path, 'builder')]
  end

  def test_builder
    yml = @reduce.get_deployment_yml('builder')
    yml.delete("vars")
    assert_equal(@base['builder'], yml)
  end

  def test_deployment_existence
    @reduce.stub(:puts, nil){
      yml = @reduce.get_deployment_yml('dep1')
      yml.delete("vars")
      assert_equal(@base['deployments']["dep1"], yml)
      assert_raises(SystemExit){@reduce.get_deployment_yml('dep3')}
      assert(Log.pop.include?("Error: invalid deployment 'dep3'!"))
    }
  end

  def test_deployment_vars_with_defaults
    vars = @reduce.get_deployment_yml('dep1')['vars']
    assert(vars["timezone"] == "US/Mountain")
  end

  def test_deployment_vars_with_overrides
    yml = @reduce.get_deployment_yml('dep2')
    assert(yml["vars"]["timezone"] == "Africa")
    assert(yml["apps"].first["value"] == "Africa")
  end
end
