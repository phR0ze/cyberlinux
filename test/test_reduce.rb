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

class TestProfiles < Minitest::Test

  def setup
    @reduce ||= Reduce.new
    @k = @reduce.instance_variable_get(:@k)
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
        'base' => {}
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
      assert(@reduce.instance_variable_get(:@vars).label == 'CYBERLINUX_01305')
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
      assert(@profile[@k.apps]['conky'].size == 1)
      assert(@profile[@k.apps]['conky'].any?{|y| y['install']})
      assert(!@profile[@k.apps]['conky'].any?{|y| y['menu']})
    }
    @mock.expect(:[], false, [@k.deployments])

    YAML.stub(:load_file, @mock){
      @reduce.load_profile('bogus')
      assert(@profile[@k.apps]['conky'].size == 2)
    }
  end

  def test_deployments
    profile_data = {
      'deployments' => {
        'base' => {},
        'lite' => {}
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
      assert(@profile[@k.deployments].size == 1)
      assert(@profile[@k.deployments]['base'])
      assert(!@profile[@k.deployments]['lite'])
    }

    YAML.stub(:load_file, @mock){
      @reduce.load_profile('bogus')
      assert(@profile[@k.deployments].size == 2)
    }
  end

end

class TestGetLayers < Minitest::Test

  def setup
    @reduce ||= Reduce.new
    @k = @reduce.instance_variable_get(:@k)
    @reduce.load_profile('standard')
  end

  def test_getlayers_with_bad_layer_name
    @reduce.stub(:exit, nil){
      @reduce.stub(:puts, nil){
        assert_raises(NoMethodError){@reduce.getlayers('foo')}
      }
    }
  end

  def test_getlayers_with_good_layer_name_expecting_single_result
    yml = @reduce.getlayers(@k.base)
    assert(yml)
    assert_equal(yml.size, 1)
    assert_equal(yml.first, @k.base)
  end

  def test_getlayers_with_good_layer_name_expecting_multi_result
    yml = @reduce.getlayers('lite')
    assert(yml)
    assert_equal(yml.size, 3)
    assert_equal(yml, ['lite', 'shell', 'base'])
  end
end

class TestGetLayer < Minitest::Test

  def setup
    @reduce ||= Reduce.new
    @k = @reduce.instance_variable_get(:@k)
    @reduce.load_profile('personal')
  end

  def test_getlayer_with_bad_layer_name
    @reduce.stub(:exit, nil){
      @reduce.stub(:puts, nil){
        assert_raises(NoMethodError){@reduce.getlayer('foo')}
      }
    }
  end

  def test_getlayer_build
    yml = @reduce.getlayer(@k.build)
    assert(yml)
    assert_equal(yml[@k.name], @k.build)
  end

  def test_getlayer_with_good_layer_name
    yml = @reduce.getlayer(@k.base)
    assert(yml)
    assert_equal(yml[@k.name], @k.base)
  end
end

# vim: ft=ruby:ts=2:sw=2:sts=2
