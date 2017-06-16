#!/usr/bin/env ruby
require_relative 'reduce'
require 'minitest/autorun'
require 'yaml'

# https://github.com/seattlerb/minitest/blob/master/test/minitest/test_minitest_mock.rb
class TestFileInsert < Minitest::Test
  parallelize_me!

  def setup
    @file = 'foo'
    @data = ['Lorem ipsum de foo bar']
    @reduce = Reduce.new

    @mock = Minitest::Mock.new
    @mock.expect(:readlines, @data)
    @mock.expect(:seek, nil, [0])
    @mock.expect(:truncate, nil, [0])
  end

  def test_single_append
    @mock.expect(:puts, nil, [@data + ['foo']])

    FileUtils.stub(:touch, true, @file){
      File.stub(:exist?, false, @file){
        File.stub(:open, true, @mock){
          @reduce.file_insert(@file, 'foo')
        }
      }
    }

    assert_mock @mock
  end
end

# vim: ft=ruby:ts=2:sw=2:sts=2
