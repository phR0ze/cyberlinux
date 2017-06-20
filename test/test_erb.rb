#!/usr/bin/env ruby
require 'minitest/autorun'
require 'ostruct'

require_relative '../lib/erb'

class TestErb < Minitest::Test

  def setup
    @vars ||= {'arch' => 'x86_64','release' => '4.7.4-1', 'distro' => 'cyberlinux'}
  end

  def test_erb_with_openstruct_vars
    vars = OpenStruct.new({'arch' => 'x86_64','release' => '4.7.4-1', 'distro' => 'cyberlinux'})
    assert_equal("<%= arch %>".erb(vars), vars.arch)
  end

  def test_erb_with_string
    assert_equal("<%= arch %>".erb(@vars), @vars['arch'])
    assert_equal("<%= arch %>".erb(arch: 'foo'), 'foo')
  end

  def test_erb_with_hash
    assert_equal({'foo' => "<%= arch %>"}.erb(@vars), {'foo' => @vars['arch']})
    assert_equal({'foo' => "<%= arch %>"}.erb(arch: 'foo'), {'foo' => 'foo'})
  end

  def test_erb_with_list
    assert_equal(['foo', "<%= arch %>"].erb(@vars), ['foo', @vars['arch']])
    assert_equal(['foo', "<%= arch %>"].erb(arch: 'foo'), ['foo', 'foo'])
  end

  def test_erb_with_string_for_multiples
    assert_equal("<%= distro %> <%= arch %>".erb(@vars), "#{@vars['distro']} #{@vars['arch']}")
    assert_equal("<%= arch %> <%= arch %>".erb(@vars), "#{@vars['arch']} #{@vars['arch']}")
  end

  def test_erb_with_combination
    assert_equal(["<%= arch %>", {'bob' => "<%= distro %>"}].erb(@vars),
      [@vars['arch'], {'bob' => @vars['distro']}])
  end
end

# vim: ft=ruby:ts=2:sw=2:sts=2
