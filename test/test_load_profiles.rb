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

class Test_load_profiles < Minitest::Test

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
        "machine" => {
          "type" => "machine",
          "multilib" => false,
          "vars" => {"fontsize" => 10},
          "install" => {
            "kernel" => "linux"
          }
        }
      },
      "builder" => {
        "type" => "container",
        "multilib" => true,
        "docker" => {
          "params" => '-e TERM=xterm -v /var/run/docker.sock:/var/run/docker.sock --privileged=true',
          "command" => 'bash -c "while :; do sleep 5; done"',
        },
        "apps" => ["core"]
      },
      "deployments" => {
        "shell" => {
          "apps" => [
            "core",
            "conky"
          ]
        }
      },
      "apps" => {
        "core" => [
          {"groups" => ["lp", "wheel"]},
          {"install" => "linux"}
        ],
        "server" => [
          "conky",
          {"groups" => ["server_group"]},
          {"edit" => "/etc/httpd/conf/httpd.conf", "regex" => '^(Listen).*', "value" => '\1 80'}
        ],
        "conky" => [
          {"groups" => ["conky_group"]},
          { "install" => "conky", "desc" => "Lightweight system monitor for X" }
        ]
      },
      "configs" => {}
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
      @profile = @reduce.instance_variable_get(:@profile)
    }

    @source_path = File.expand_path(File.join(File.dirname(__FILE__), '../source'))
    @base['builder']['source'] = [File.join(@source_path, 'builder')]
  end

  def teardown
    assert_mock(@base_mock)
  end

  def test_defaults
    shell = @profile.deployments['shell']
    assert(!shell[@k.multilib])
    assert_equal("linux", shell[@k.install][@k.kernel])
    assert_equal(["lp", "wheel", "conky_group"], @vars.shell_groups)
    assert_equal("lp,wheel,conky_group", @vars.groups)
    assert_equal(["lp", "wheel", "conky_group"], @vars.all_groups)
    assert_equal(10, shell[@k.vars]['fontsize'])
  end

  def test_recurse_set
    mock = Minitest::Mock.new
    mock.expect(:[], false, [@k.vars])
    mock.expect(:[], @k.base, [@k.base])
    [@k.defaults, @k.builder, @k.apps, @k.configs, @k.deployments].each{|x| mock.expect(:[], false, [x])}

    YAML.stub(:load_file, mock){
      @reduce.load_profile('bogus')
      assert_equal('bogus', @vars.profile)
      assert_equal(['base', 'bogus'], @reduce.instance_variable_get(:@loaded_profiles))
    }
  end

  def test_vars_base
    assert_equal('CYBERLINUX_01305', @vars.label)
  end

  def test_vars_child
    profile_data = {
      'vars' => {
        "release" => "999.999.999",
        "color_dark" => "#FFFFFF",
      }
    }

    mock = Minitest::Mock.new
    mock.expect(:[], true, [@k.vars])
    mock.expect(:[], profile_data[@k.vars], [@k.vars])
    [@k.base, @k.defaults, @k.builder, @k.apps, @k.configs, @k.deployments].each{|x| mock.expect(:[], false, [x])}

    YAML.stub(:load_file, mock){
      @reduce.load_profile('bogus')
      assert_equal('999.999.999', @vars.release)
      assert_equal('cyberlinux', @vars.distro)
      assert_equal('#39AEF4', @vars.color_light)
      assert_equal('#FFFFFF', @vars.color_dark)
    }
  end


  def test_builder_base
    assert_equal(@base['builder'], @profile.builder)
    assert_equal(1, @profile.builder['apps'].size)
    assert_equal(["core"], @profile.builder['apps'])
    assert_equal(["lp", "wheel"], @vars.builder_groups)
  end

  def test_builder_child
    profile_data = {
      'builder' => {
        'apps' => ['conky']
      }
    }
    mock = Minitest::Mock.new
    [@k.vars, @k.base, @k.defaults].each{|x| mock.expect(:[], false, [x])}
    mock.expect(:[], true, [@k.builder])
    mock.expect(:[], profile_data[@k.builder], [@k.builder])
    [@k.apps, @k.configs, @k.deployments].each{|x| mock.expect(:[], false, [x])}

    expected_builder = @base[@k.builder]
    expected_builder[@k.apps] = ['conky']
    YAML.stub(:load_file, mock){
      @reduce.load_profile('bogus')
      assert_equal(expected_builder, @profile.builder)
      assert_equal(["conky_group"], @vars.builder_groups)
    }
  end

  def test_apps_base
    profile_data = {
      'apps' => {
        'lite' => ['conky'],
        'conky' => [
          { 'install' => 'conky', 'desc' => 'Lightweight system monitor for X' },
          { 'menu' => 'Settings', 'entry' => 'Conky RC', 'icon' => 'gvim.png', 'exec' => 'gvim ~/.conkyrc' }
        ]
      }
    }

    mock = Minitest::Mock.new
    [@k.vars, @k.base, @k.defaults, @k.builder].each{|x| mock.expect(:[], false, [x])}
    mock.expect(:[], true, [@k.apps])
    mock.expect(:[], profile_data[@k.apps]){|x|
      assert_equal(2, @profile.apps['conky'].size)
      assert(@profile.apps['conky'].any?{|y| y['groups']})
      assert(@profile.apps['conky'].any?{|y| y['install']})
      assert(!@profile.apps['conky'].any?{|y| y['menu']})
    }
    [@k.configs, @k.deployments].each{|x| mock.expect(:[], false, [x])}

    YAML.stub(:load_file, mock){
      @reduce.load_profile('bogus')
      assert(1, @profile.apps['conky'].size)
    }
  end

  def test_apps_child
    profile0 = {
      "apps" => {
        "profile0-app" => [{"install" => "profile0-pkg"}]
      }
    }
    profile1 = {
      "base" => "profile0",
      "apps" => {
        "profile1-app" => [{"install" => "profile1-pkg"}]
      }
    }
    profile2 = {
      "base" => "profile1",
      "apps" => {
        "server" => ["conky"],
        "conky" => [{"install" => "profile2-pkg"}]
      }
    }

    mock = Minitest::Mock.new

    # profile2
    mock.expect(:[], false, [@k.vars])
    mock.expect(:[], 'profile1', [@k.base])

    # profile1
    mock.expect(:[], false, [@k.vars])
    mock.expect(:[], 'profile0', [@k.base])

    # profile0
    mock.expect(:[], false, [@k.vars])
    mock.expect(:[], 'base', [@k.base])
    mock.expect(:[], false, [@k.defaults])
    mock.expect(:[], false, [@k.builder])
    mock.expect(:[], true, [@k.apps])
    mock.expect(:[], profile0[@k.apps], [@k.apps])
    [@k.configs, @k.deployments].each{|x| mock.expect(:[], false, [x])}

    # profile1
    mock.expect(:[], false, [@k.defaults])
    mock.expect(:[], false, [@k.builder])
    mock.expect(:[], true, [@k.apps])
    mock.expect(:[], profile1[@k.apps], [@k.apps])
    [@k.configs, @k.deployments].each{|x| mock.expect(:[], false, [x])}

    # profile2
    mock.expect(:[], false, [@k.defaults])
    mock.expect(:[], false, [@k.builder])
    mock.expect(:[], true, [@k.apps])
    mock.expect(:[], profile2[@k.apps], [@k.apps])
    [@k.configs, @k.deployments].each{|x| mock.expect(:[], false, [x])}

    YAML.stub(:load_file, mock){
      @reduce.load_profile('profile2')
      assert_equal('profile2', @vars.profile)
      assert_equal(['base', 'profile0', 'profile1', 'profile2'], @reduce.instance_variable_get(:@loaded_profiles))
      assert_equal({
        "core" => [
          {"groups" => ["lp", "wheel"]},
          {"install" => "linux"}
        ],
        "server" => ["conky"],
        "conky" => [{"install" => "profile2-pkg"}],
        "profile0-app" => [{"install" => "profile0-pkg"}],
        "profile1-app" => [{"install" => "profile1-pkg"}]
      }, @profile.apps)
    }
  end

  def test_deployments
    profile_data = {
      'deployments' => {
        'shell' => {
          'apps' => ['server']
        },
        'lite' => {
          'type' => 'container',
        }
      }
    }

    mock = Minitest::Mock.new
    [@k.vars, @k.base, @k.defaults, @k.builder, @k.apps, @k.configs].each{|x| mock.expect(:[], false, [x])}

    # Validate base
    mock.expect(:[], true, [@k.deployments])
    mock.expect(:[], profile_data[@k.deployments]){|x|
      assert_equal(1, @profile.deployments.size)
      assert(@profile.deployments['shell'])
      assert_equal(["core", "conky"], @profile.deployments['shell']['apps'])
      assert(!@profile[@k.deployments]['lite'])
    }

    # Validate child
    YAML.stub(:load_file, mock){
      @reduce.load_profile('bogus')
      assert_equal(2, @profile.deployments.size)
      assert(@profile.deployments['shell'])
      assert_equal(["server"], @profile.deployments['shell']['apps'])
      assert(@profile[@k.deployments]['lite'])
    }
  end

  def test_deployment_vars
   profile_data = {
      'deployments' => {
        'shell' => {
          'apps' => ["conky"]
        },
        'server' => {
          'apps' => ["server"]
        },
        'heavy' => {
          'base' => 'shell'
        }
      }
    }

    mock = Minitest::Mock.new
    [@k.vars, @k.base, @k.defaults, @k.builder, @k.apps, @k.configs].each{|x| mock.expect(:[], false, [x])}
    mock.expect(:[], true, [@k.deployments])
    mock.expect(:[], profile_data[@k.deployments], [@k.deployments])

    YAML.stub(:load_file, mock){
      @reduce.load_profile('bogus')
      assert_equal(["lp", "wheel"], @vars.builder_groups)
      assert_nil(@profile.deployments['shell']['base'])
      assert_equal('shell', @vars.shell_deployment)
      assert_nil(@vars.lite_deployment)
      assert_equal('heavy,shell', @vars.heavy_deployment)
      assert_equal(["conky_group"], @vars.shell_groups)
      assert(@vars.heavy_groups.empty?)
    }
  end
end
