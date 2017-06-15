#!/usr/bin/env ruby
require_relative 'reduce'
require 'minitest/autorun'
require 'yaml'

class TestFileInsert < Minitest::Test
  def setup
    @file = 'foo'
    @reduce = Reduce.new
  end

  # Append, create file
  def test_multi_value_no_regex_create_file

    # Using mocks
    #mock = Minitest::Mock.new
    #mock.expect(:readlines, 'Lorem ipsum de foo bar')
    #File.stub(:open, mock){|x|
    #  puts(x.readlines)
    #}
    #assert_mock mock

    # Using stubs
    FileUtils.stub(:touch, 'foo'){|x|
      File.stub(:exist?, false, 'foo'){|x|
        FileUtils.touch('foo') if not File.exist?('foo')
      }
    }
  end
end

# vim: ft=ruby:ts=2:sw=2:sts=2
