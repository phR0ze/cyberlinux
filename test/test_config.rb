#!/usr/bin/env ruby
#MIT License
#Copyright (c) 2017 phR0ze
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

require 'minitest/autorun'
require 'ostruct'

require_relative '../lib/config'
require_relative '../lib/fedit'
require_relative '../lib/sys'

class TestApply < Minitest::Test

  def setup
    @file = 'foo'
    @ctx = OpenStruct.new({
      root: '/de',
      vars: {
        var1: 'var1',
        file_var: '/foo'
      },
      configs: {
        'config-foobar1' => [
          { 'edit' => '/foo', 'append' => 'after', 'value' => 'bar', 'regex' => '/bob/' }
        ],
        'config-foobar2' => [
          { 'edit' => '<%= file_var %>', 'append' => 'after', 'value' => 'bar', 'regex' => '/bob/' }
        ]
      }
    })
  end

  def test_apply_with_exec
    ctx = OpenStruct.new({ root: '.', vars: { var1: 'var1', file_var: '/foo' } })

    Sys.stub(:puts, nil){
      refute(Config.apply({'exec' => 'touch /foo'}, ctx))
      assert(File.exist?('foo'))
      refute(Config.apply({'exec' => 'rm /foo'}, ctx))
      refute(File.exist?('foo'))
    }
  end

  def test_apply_with_templating_reference
    config = { 'apply' => 'config-foobar2'}
    config_insert_helper(config, 1)
  end

  def test_apply_with_templating
    config = { 'edit' => '<%= file_var %>', 'append' => 'after', 'value' => 'bar', 'regex' => '/bob/' }
    config_insert_helper(config, 1)
  end

  def test_apply_with_resolve
    config = { 'resolve' => '/foo' }

    assert_args = ->(file, vars){
      assert_equal(File.join(@ctx.root, @file), file)
      assert_equal(@ctx.vars, vars)
      true
    }

    Fedit.stub(:resolve, assert_args){
      assert(Config.apply(config, @ctx))
    }
  end

  def test_apply_with_apply_reference_fail
    config = { 'apply' => 'config-bar' }
    assert_raises(NoMethodError){config_insert_helper(config, 1)}
  end

  def test_apply_with_apply_reference_success
    config = { 'apply' => 'config-foobar1' }
    config_insert_helper(config, 1)
  end

  def test_apply_file_doesnt_exist
    config = { 'edit' => '/foo', 'value' => 'bar' }

    Config.stub(:puts, nil){
      FileUtils.stub(:mkdir_p, true, @file){
        File.stub(:exist?, false, @file){
          Fedit.stub(:insert, true, @file){
            assert(Config.apply(config, @ctx))
          }
        }
      }
    }
  end

  def test_apply_replace
    config = { 'edit' => '/foo', 'regex' => '/bob/', 'value' => 'bar' }

    mock = Minitest::Mock.new
    mock.expect(:=~, false, [Regexp.new(Regexp.quote('bar'))])

    assert_args = ->(file, regex, value){
      assert_equal(File.join(@ctx.root, @file), file)
      assert_equal('/bob/', regex)
      assert_equal('bar', value)
      true
    }

    Config.stub(:puts, nil){
      File.stub(:exist?, true, @file){
        File.stub(:binread, mock, @file){
          Fedit.stub(:replace, assert_args){
            assert(Config.apply(config, @ctx))
          }
        }
      }
    }

    assert_mock(mock)
  end

  def config_insert_helper(config, offset)
    mock = Minitest::Mock.new
    mock.expect(:=~, false, [Regexp.new(Regexp.quote('bar'))])

    assert_args = ->(file, values, opts){
      assert_equal(File.join(@ctx.root, @file), file)
      assert_equal(['bar'], values)
      assert_equal('/bob/', opts[:regex])
      opts[:offset] ? assert_equal(offset, opts[:offset]) : assert_nil(opts[:offset])
      true
    }

    Config.stub(:puts, nil){
      File.stub(:exist?, true, @file){
        File.stub(:binread, mock, @file){
          Fedit.stub(:insert, assert_args){
            assert(Config.apply(config, @ctx))
          }
        }
      }
    }

    assert_mock(mock)
  end

  def test_apply_insert
    config = { 'edit' => '/foo', 'append' => 'after', 'value' => 'bar', 'regex' => '/bob/' }
    config_insert_helper(config, 1)
    config['append'] = 'before'
    config_insert_helper(config, 0)
    config['append'] = true
    config_insert_helper(config, nil)
  end

  def test_apply_append
    config = { 'edit' => '/foo', 'append' => true, 'value' => 'bar' }

    mock = Minitest::Mock.new
    mock.expect(:=~, false, [Regexp.new(Regexp.quote('bar'))])

    assert_args = ->(file, values, opts){
      assert_equal(File.join(@ctx.root, @file), file)
      assert_equal(['bar'], values)
      assert_nil(opts[:regex])
      assert_nil(opts[:offset])
      true
    }

    Config.stub(:puts, nil){
      File.stub(:exist?, true, @file){
        File.stub(:binread, mock, @file){
          Fedit.stub(:insert, assert_args){
            assert(Config.apply(config, @ctx))
          }
        }
      }
    }

    assert_mock(mock)
  end
end

class TestRedirect < Minitest::Test

  def setup
    @ctx = OpenStruct.new({ root: '/de' })
  end

  def test_reusing_config_multiple_times
    config = {'exec' => "touch /foo"}
    ctx = OpenStruct.new({ root: '/build' })
    assert_equal({'exec' => "touch /build/foo"}, Config.redirect(config, ctx, Config.keys))
    ctx = OpenStruct.new({ root: '/base' })
    assert_equal({'exec' => "touch /base/foo"}, Config.redirect(config, ctx, Config.keys))
  end

  def test_redirect_with_relative_root
    config = {'exec' => "touch /foo"}
    ctx = OpenStruct.new({ root: '.' })
    assert_equal({'exec' => "touch ./foo"}, Config.redirect(config, ctx, Config.keys))
  end

  def test_redirect_with_exec_multi
    config = {'exec' => "touch //foo && echo '/foo' > /foo; tee /foo2 /foo3"}
    assert_equal({'exec' => "touch /foo && echo '/foo' > /de/foo; tee /de/foo2 /de/foo3"},
      Config.redirect(config, @ctx, Config.keys))
  end

  def test_redirect_with_exec_combo
    config = {'exec' => "touch //foo && echo '/foo' > /foo"}
    assert_equal({'exec' => "touch /foo && echo '/foo' > /de/foo"}, Config.redirect(config, @ctx, Config.keys))
  end

  def test_redirect_with_exec_host
    config = {'exec' => 'touch //foo'}
    assert_equal({'exec' => 'touch /foo'}, Config.redirect(config, @ctx, Config.keys))
  end

  def test_redirect_with_exec
    config = {'exec' => 'touch /foo'}
    assert_equal({'exec' => 'touch /de/foo'}, Config.redirect(config, @ctx, Config.keys))
  end

  def test_redirect_with_bogus
    config = {'bogus' => '/foo'}
    assert_raises(ArgumentError){Config.redirect(config, @ctx, Config.keys)}
  end

  def test_redirect_with_resolve_host
    config= {'resolve' => '//foo'}
    assert_equal({'resolve' => '/foo'}, Config.redirect(config, @ctx, Config.keys))
  end

  def test_redirect_with_resolve
    config = {'resolve' => '/foo'}
    assert_equal({'resolve' => '/de/foo'}, Config.redirect(config, @ctx, Config.keys))
  end

  def test_redirect_with_edit_host
    config = {'edit' => '//foo'}
    assert_equal({'edit' => '/foo'}, Config.redirect(config, @ctx, Config.keys))
  end

  def test_redirect_with_edit
    config = {'edit' => '/foo'}
    assert_equal({'edit' => '/de/foo'}, Config.redirect(config, @ctx, Config.keys))
  end
end

# vim: ft=ruby:ts=2:sw=2:sts=2
