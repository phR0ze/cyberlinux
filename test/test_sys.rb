#!/usr/bin/env ruby
require 'minitest/autorun'
require 'ostruct'

require_relative '../lib/sys'

class TestSys < Minitest::Test

  def test_rm_rf_with_tmp_file
    Sys.stub(:puts, nil){
      assert(Sys.exec("touch foobar"))
      assert(File.exist?('foobar'))
      assert_equal(Sys.rm_rf('foobar'), 'foobar')
      refute(File.exist?('foobar'))
    }
  end

  def test_rm_rf_with_bogus_file
    Sys.stub(:puts, nil){
      assert_equal(Sys.rm_rf('bogus'), 'bogus')
    }
  end
end

# vim: ft=ruby:ts=2:sw=2:sts=2
