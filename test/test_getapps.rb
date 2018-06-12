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

class Test_getapps < Minitest::Test

  def setup
    @reduce ||= Reduce.new
    @k = @reduce.instance_variable_get(:@k)
    @profile = @reduce.instance_variable_get(:@profile)

    @data = {
      'deployments' => {
        'base' => {
          'multilib' => false,
          'apps' => [
            'base-apps',
          ]
        },
        'server' => {
          'multilib' => true,
          'apps' => [
            'server-apps',
          ]
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
          'phpBB',
          { 'chroot' => 'systemctl enable httpd.service' }
        ],
        'conky' => [
          { 'install' => 'conky', 'desc' => 'Lightweight system monitor for X' },
          { 'exec' => 'echo 1 >> foobar' }
        ],
        'phpBB' => [
          { 'install' => 'apache', 'desc' => 'Apache web server' }
        ]
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

  def test_pkgs
    apache = [{ 'install' => 'apache', 'desc' => 'Apache web server' }]
    conky = [{ 'install' => 'conky', 'desc' => 'Lightweight system monitor for X'}]
    curl = [{ 'install' => 'curl', 'desc' => 'Network download REST command line tool' }]
    lib = [{ 'install' => 'gcc-libs', 'desc' => 'GCC runtime libraries', 'multilib' => false }]
    multilib = [{ 'install' => 'gcc-libs-multilib', 'desc' => 'GCC runtime libraries', 'multilib' => true }]

    @reduce.stub(:puts, nil){
      pkgs, _ = @reduce.getapps('base', @data[@k.deployments]['base'])
      assert_equal(conky + curl + lib, pkgs)
      pkgs, _ = @reduce.getapps('server', @data[@k.deployments]['server'])
      assert_equal(apache + conky + curl + multilib, pkgs)
    }
  end

  def test_configs
    result1 = [{ 'exec' => 'echo 1 >> foobar' }]
    result2 = result1 + [{ 'chroot' => 'systemctl enable httpd.service' }]

    @reduce.stub(:puts, nil){
      _, configs = @reduce.getapps('base', @data[@k.deployments]['base'])
      assert_equal(result1, configs)
      _, configs = @reduce.getapps('server', @data[@k.deployments]['server'])
      assert_equal(result2, configs)
    }
  end
end
