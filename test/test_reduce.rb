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
    @reduce ||= Reduce.new
    @k = @reduce.instance_variable_get(:@k)
    @vars = @reduce.instance_variable_get(:@vars)
    @profile = @reduce.instance_variable_get(:@profile)

    @base_data = {
      'vars' => {
        'arch' => 'x86_64',
        'release' => '0.1.305',
        'distro' => 'cyberlinux',
        'language' => 'en_US',
        'character_set' => 'UTF=8',
        'timezone' => 'US/Mountain',
        'country' => 'United_States',
        'color_light' => '#39AEF4',
        'color_dark' => '#215A94',
        'gfxmode' => '1280x1024',
        'grub_iso_theme' => '/boot/grub/themes/cyberlinux'
      },
      'apps' => {
        'server-apps' => ['conky'],
        'conky' => [
          { 'install' => 'conky', 'desc' => 'Lightweight system monitor for X' }
        ]
      },
      'deployments' => {
        'base' => {
          'type' => 'machine',
          'groups' => ['group1']
        }
      }
    }
    @mock = Minitest::Mock.new

    # vars/base check on child profile
    @mock.expect(:[], false, [@k.vars])
    @mock.expect(:[], true, [@k.base])
    @mock.expect(:[], '_base', [@k.base])

    # vars/base check on base profile
    @mock.expect(:[], true, [@k.vars])
    @mock.expect(:[], @base_data[@k.vars], [@k.vars])
    @mock.expect(:[], false, [@k.base])
  end

  def teardown
    assert_mock(@mock)
  end

  def test_vars
    # ignore other calls tested elsewhere
    @mock.expect(:[], false, [@k.apps])
    @mock.expect(:[], false, [@k.deployments])
    @mock.expect(:[], false, [@k.apps])
    @mock.expect(:[], false, [@k.deployments])

    YAML.stub(:load_file, @mock){
      @reduce.load_profile('bogus')
      assert_equal('CYBERLINUX_01305', @vars.label)
    }
  end

  def test_apps
    profile_data = {
      'apps' => {
        'lite-apps' => ['conky'],
        'conky' => [
          { 'install' => 'conky', 'desc' => 'Lightweight system monitor for X' },
          { 'menu' => 'Settings', 'entry' => 'Conky RC', 'icon' => 'gvim.png', 'exec' => 'gvim ~/.conkyrc' }
        ]
      }
    }

    # Mock/test out the base profile
    @mock.expect(:[], true, [@k.apps])
    @mock.expect(:[], @base_data[@k.apps], [@k.apps])
    @mock.expect(:[], false, [@k.deployments])

    # Mock/test out the child profile
    @mock.expect(:[], true, [@k.apps])
    @mock.expect(:[], profile_data[@k.apps]){|x|
      assert_equal(1, @profile[@k.apps]['conky'].size)
      assert(@profile[@k.apps]['conky'].any?{|y| y['install']})
      assert(!@profile[@k.apps]['conky'].any?{|y| y['menu']})
    }
    @mock.expect(:[], false, [@k.deployments])

    YAML.stub(:load_file, @mock){
      @reduce.load_profile('bogus')
      assert(1, @profile[@k.apps]['conky'].size)
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

    # Mock/test out the base profile
    @mock.expect(:[], false, [@k.apps])
    @mock.expect(:[], true, [@k.deployments])
    @mock.expect(:[], @base_data[@k.deployments], [@k.deployments])

    # Mock/test out the child profile
    @mock.expect(:[], false, [@k.apps])
    @mock.expect(:[], true, [@k.deployments])
    @mock.expect(:[], profile_data[@k.deployments]){|x|
      assert_equal(1, @profile[@k.deployments].size)
      assert(@profile[@k.deployments]['base'])
      assert(!@profile[@k.deployments]['lite'])
    }

    YAML.stub(:load_file, @mock){
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

    # ignore other calls tested elsewhere
    @mock.expect(:[], false, [@k.apps])
    @mock.expect(:[], true, [@k.deployments])
    @mock.expect(:[], @base_data[@k.deployments], [@k.deployments])
    @mock.expect(:[], false, [@k.apps])
    @mock.expect(:[], true, [@k.deployments])
    @mock.expect(:[], profile_data[@k.deployments], [@k.deployments])

    YAML.stub(:load_file, @mock){
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

class Test_get_deployments < Minitest::Test

  def setup
    @reduce ||= Reduce.new
    @k = @reduce.instance_variable_get(:@k)
    @profile = @reduce.instance_variable_get(:@profile)

    @base_data = {
      'deployments' => {
        'dep1' => { 'type' => 'machine' },
        'dep2' => { 'type' => 'machine', 'base' => 'dep1' }
      }
    }

    @mock = Minitest::Mock.new
    @mock.expect(:[], false, [@k.vars])
    @mock.expect(:[], false, [@k.base])
    @mock.expect(:[], false, [@k.apps])
    @mock.expect(:[], true, [@k.deployments])
    @mock.expect(:[], @base_data[@k.deployments], [@k.deployments])
    YAML.stub(:load_file, @mock){ @reduce.load_profile('bogus') }
  end

  def test_deployment_existence
    @reduce.stub(:exit, nil){
      @reduce.stub(:puts, nil){
        assert(NoMethodError){@reduce.get_deployments('dep1')}
        assert_raises(NoMethodError){@reduce.get_deployments('dep3')}
      }
    }
  end

  def test_deployment_expecting_single_result
    names = @reduce.get_deployments('dep1')
    assert(names)
    assert_equal(1, names.size)
    assert_equal('dep1', names.first)
  end

  def test_deployment_expecting_multi_result
    names = @reduce.get_deployments('dep2')
    assert(names)
    assert_equal(2, names.size)
    # order is important here
    assert_equal(['dep2', 'dep1'], names)
  end

  def test_deployment_yml_bad_name
    @reduce.stub(:exit, nil){
      @reduce.stub(:puts, nil){
        assert(NoMethodError){@reduce.get_deployments('dep1')}
        assert_raises(NoMethodError){@reduce.get_deployments('dep3')}
      }
    }
  end

  def test_deployment_yml_good
    yml = @reduce.get_deployment_yml('dep2')
    assert(yml)
    assert_equal('dep1', yml[@k.base])
  end
end

class Test_getpkgs < Minitest::Test

  def setup
    @reduce ||= Reduce.new
    @k = @reduce.instance_variable_get(:@k)
    @profile = @reduce.instance_variable_get(:@profile)

    @data = {
      'apps' => {
        'server-apps' => ['conky'],
        'conky' => [
          { 'install' => 'conky', 'desc' => 'Lightweight system monitor for X' }
        ]
      },
      'deployments' => {
        'dep1' => { 'type' => 'machine' },
        'dep2' => { 'type' => 'machine', 'base' => 'dep1' }
      }
    }

    @mock = Minitest::Mock.new
    @mock.expect(:[], false, [@k.vars])
    @mock.expect(:[], false, [@k.base])
    @mock.expect(:[], true, [@k.apps])
    @mock.expect(:[], @data[@k.apps], [@k.apps])
    @mock.expect(:[], true, [@k.deployments])
    @mock.expect(:[], @data[@k.deployments], [@k.deployments])
    YAML.stub(:load_file, @mock){ @reduce.load_profile('bogus') }
  end

  def test_getpkgs_get_all
    @reduce.stub(:puts, nil){
      pkgs = @reduce.getpkgs
    }
  end
end

# vim: ft=ruby:ts=2:sw=2:sts=2
