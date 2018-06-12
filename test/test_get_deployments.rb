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
