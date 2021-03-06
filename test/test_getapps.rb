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
          { 'install' => 'gcc-libs-multilib', 'desc' => 'GCC runtime libraries', 'multilib' => true },
          { 'install-nested' => [{'install' => 'foo'}, {'exec' => 'foo'}]}
        ],
        'server-apps' => [
          'base-apps',
          'phpBB'
        ],
        'conky' => [
          { 'groups' => ['conky_group']},
          { 'install' => 'conky', 'desc' => 'Lightweight system monitor for X' },
          { 'exec' => 'echo 1 >> <%=country%>' }
        ],
        'phpBB' => [
          { 'install' => 'apache', 'desc' => 'Apache web server' }
        ]
      },
      "configs" => {
        "server-configs" => [
          { 'groups' => ['server_group']},
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
      @profile = @reduce.instance_variable_get(:@profile)
    }
  end

  def teardown
    assert_mock(@base_mock)
  end

  def test_pkgs
    apache = [{ 'install' => 'apache', 'desc' => 'Apache web server' }]
    conky = [{ 'install' => 'conky', 'desc' => 'Lightweight system monitor for X'}]
    curl = [{ 'install' => 'curl', 'desc' => 'Network download REST command line tool' }]
    foo = [{ 'install' => 'foo'}]
    lib = [{ 'install' => 'gcc-libs', 'desc' => 'GCC runtime libraries', 'multilib' => false }]
    multilib = [{ 'install' => 'gcc-libs-multilib', 'desc' => 'GCC runtime libraries', 'multilib' => true }]

    @reduce.stub(:puts, nil){
      pkgs, _ = @reduce.getapps('base', @reduce.get_deployment_yml('base'))
      assert_equal(conky + curl + foo + lib, pkgs)
      pkgs, _ = @reduce.getapps('server', @reduce.get_deployment_yml('server'))
      assert_equal(apache + conky + curl + foo + multilib, pkgs)
    }
  end

  def test_configs
    groups = [{'groups' => ['conky_group']}]
    country = [{ 'exec' => 'echo 1 >> United_States' }]
    foo = [{ 'exec' => 'foo' }]
    result2 = groups + country + foo + [
      {'groups' => ['server_group']},
      { 'chroot' => 'systemctl enable httpd.service' },
      {"edit" => "/etc/httpd/conf/httpd.conf", "regex" => '^(timezone).*', "value" => 'Africa'}]

    @reduce.stub(:puts, nil){
      _, configs = @reduce.getapps('base', @reduce.get_deployment_yml('base'))
      assert_equal(groups + country + foo, configs)
      _, configs = @reduce.getapps('server', @reduce.get_deployment_yml('server'))
      assert_equal(result2, configs)
    }
  end

  def test_deployment_has_no_apps
     @reduce.stub(:puts, nil){
      apps, configs = @reduce.getapps('live', @reduce.get_deployment_yml('live'))
      assert_equal([], apps)
      assert_equal([], configs)
    }
  end
end
