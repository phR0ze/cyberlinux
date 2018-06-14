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
      "deployments" => {
        "base" => {
          "type" => "machine",
          "groups" => ["group1"]
        }
      },
      "apps" => {
        "server-apps" => ["conky"],
        "conky" => [
          { "install" => "conky", "desc" => "Lightweight system monitor for X" }
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
      @vars = @reduce.instance_variable_get(:@vars)
      @profile = @reduce.instance_variable_get(:@profile)
    }
  end

  def teardown
    assert_mock(@base_mock)
  end

  def test_recurse_set
    mock = Minitest::Mock.new
    mock.expect(:[], false, [@k.vars])
    mock.expect(:[], 'base', [@k.base])
    [@k.build, @k.apps, @k.configs, @k.deployments].each{|x| mock.expect(:[], false, [x])}

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
    [@k.base, @k.build, @k.apps, @k.configs, @k.deployments].each{|x| mock.expect(:[], false, [x])}

    YAML.stub(:load_file, mock){
      @reduce.load_profile('bogus')
      assert_equal('999.999.999', @vars.release)
      assert_equal('cyberlinux', @vars.distro)
      assert_equal('#39AEF4', @vars.color_light)
      assert_equal('#FFFFFF', @vars.color_dark)
    }
  end


  def test_build_base
    assert_equal(@profile.build, @base['build'])
  end

  def test_build_child
    profile_data = {
      'build' => {
        'apps' => [
          { 'install' => 'linux-celes'},
        ]
      }
    }

    mock = Minitest::Mock.new
    mock.expect(:[], false, [@k.vars])
    mock.expect(:[], false, [@k.base])
    mock.expect(:[], true, [@k.build])
    mock.expect(:[], profile_data[@k.build], [@k.build])
    [@k.apps, @k.configs, @k.deployments].each{|x| mock.expect(:[], false, [x])}

    expected_build = @base[@k.build]
    expected_build[@k.apps] = [{ 'install' => 'linux-celes'}]
    YAML.stub(:load_file, mock){
      @reduce.load_profile('bogus')
      assert_equal(expected_build, @profile.build)
    }
  end

  def test_apps_base
    profile_data = {
      'apps' => {
        'lite-apps' => ['conky'],
        'conky' => [
          { 'install' => 'conky', 'desc' => 'Lightweight system monitor for X' },
          { 'menu' => 'Settings', 'entry' => 'Conky RC', 'icon' => 'gvim.png', 'exec' => 'gvim ~/.conkyrc' }
        ]
      }
    }

    mock = Minitest::Mock.new
    [@k.vars, @k.base, @k.build].each{|x| mock.expect(:[], false, [x])}
    mock.expect(:[], true, [@k.apps])
    mock.expect(:[], profile_data[@k.apps]){|x|
      assert_equal(1, @profile[@k.apps]['conky'].size)
      assert(@profile[@k.apps]['conky'].any?{|y| y['install']})
      assert(!@profile[@k.apps]['conky'].any?{|y| y['menu']})
    }
    [@k.configs, @k.deployments].each{|x| mock.expect(:[], false, [x])}

    YAML.stub(:load_file, mock){
      @reduce.load_profile('bogus')
      assert(1, @profile[@k.apps]['conky'].size)
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
        "server-apps" => ["conky"],
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
    mock.expect(:[], false, [@k.build])
    mock.expect(:[], true, [@k.apps])
    mock.expect(:[], profile0[@k.apps], [@k.apps])
    [@k.configs, @k.deployments].each{|x| mock.expect(:[], false, [x])}

    # profile1
    mock.expect(:[], false, [@k.build])
    mock.expect(:[], true, [@k.apps])
    mock.expect(:[], profile1[@k.apps], [@k.apps])
    [@k.configs, @k.deployments].each{|x| mock.expect(:[], false, [x])}

    # profile2
    mock.expect(:[], false, [@k.build])
    mock.expect(:[], true, [@k.apps])
    mock.expect(:[], profile2[@k.apps], [@k.apps])
    [@k.configs, @k.deployments].each{|x| mock.expect(:[], false, [x])}

    YAML.stub(:load_file, mock){
      @reduce.load_profile('profile2')
      assert_equal('profile2', @vars.profile)
      assert_equal(['base', 'profile0', 'profile1', 'profile2'], @reduce.instance_variable_get(:@loaded_profiles))
      assert_equal({
        "server-apps" => ["conky"],
        "conky" => [{"install" => "profile2-pkg"}],
        "profile0-app" => [{"install" => "profile0-pkg"}],
        "profile1-app" => [{"install" => "profile1-pkg"}]
      }, @profile.apps)
    }
  end

  def test_deployments
    profile_data = {
      'deployments' => {
        'base' => {
          'type' => 'machine',
          'groups' => ['group1']
        },
        'lite' => {
          'type' => 'container',
          'groups' => ['group2']
        }
      }
    }

    mock = Minitest::Mock.new
    [@k.vars, @k.base, @k.build, @k.apps, @k.configs].each{|x| mock.expect(:[], false, [x])}
    mock.expect(:[], true, [@k.deployments])
    mock.expect(:[], profile_data[@k.deployments]){|x|
      assert_equal(1, @profile[@k.deployments].size)
      assert(@profile[@k.deployments]['base'])
      assert(!@profile[@k.deployments]['lite'])
    }

    YAML.stub(:load_file, mock){
      @reduce.load_profile('bogus')
      assert_equal(2, @profile[@k.deployments].size)
    }
  end

  def test_deployment_vars
   profile_data = {
      'deployments' => {
        'base' => {
          'type' => 'machine',
          'groups' => ['group1']
        },
        'lite' => {
          'type' => 'container',
          'groups' => ['group2']
        },
        'heavy' => {
          'type' => 'machine',
          'base' => 'base',
          'groups' => ['group3', 'group4']
        }
      }
    }

    mock = Minitest::Mock.new
    [@k.vars, @k.base, @k.build, @k.apps, @k.configs].each{|x| mock.expect(:[], false, [x])}
    mock.expect(:[], true, [@k.deployments])
    mock.expect(:[], profile_data[@k.deployments], [@k.deployments])

    YAML.stub(:load_file, mock){
      @reduce.load_profile('bogus')
      assert_equal('base', @vars.base_deployment)
      assert_nil(@vars.lite_deployment)
      assert_equal('heavy,base', @vars.heavy_deployment)
      assert_equal('group1', @vars.base_groups)
      assert_equal('group2', @vars.lite_groups)
      assert_equal('group3,group4,group1', @vars.heavy_groups)
    }
  end

end
