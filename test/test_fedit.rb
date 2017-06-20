#!/usr/bin/env ruby
require 'minitest/autorun'
require 'ostruct'

require_relative '../lib/fedit'

class TestResolveTemplate < Minitest::Test

  def setup
    @vars ||= {'arch' => 'x86_64','release' => '4.7.4-1', 'distro' => 'cyberlinux'}

    @resolve_template_stub ||= ->(mock, file, vars){
      File.stub(:open, true, mock){
        resolve_template(file, vars)
      }
    }
  end

  def test_resolve_template_missing_var
    data = "bar1\n<%= bar %>\nbar3"
    mock = Minitest::Mock.new
    mock.expect(:read, data)
    mock.expect(:<<, data, [data])

    assert_raises(NameError){@resolve_template_stub[mock, 'foo', @vars]}
    assert_mock mock
  end

  def test_resolve_template_with_change
    data = "bar1\n<%= distro %>\nbar3"
    _data = "bar1\ncyberlinux\nbar3"
    mock = Minitest::Mock.new
    mock.expect(:read, data)
    mock.expect(:seek, nil, [0])
    mock.expect(:truncate, nil, [0])
    mock.expect(:puts, nil){|x| x == _data }

    assert(@resolve_template_stub[mock, 'foo', @vars])
    assert_mock mock
  end

  def test_resolve_template_with_single_file_and_no_change
    data = "bar1\nbar2\nbar3"
    mock = Minitest::Mock.new
    mock.expect(:read, data)

    refute(@resolve_template_stub[mock, 'foo', @vars])
    assert_mock mock
  end
end

class TestFileInsert < Minitest::Test

  def setup
    @file ||= 'foo'

    @file_insert_stub ||= ->(mock, file, values, regex:nil, offset:1){
      FileUtils.stub(:touch, true, file){
        File.stub(:exist?, false, file){
          File.stub(:open, true, mock){
            file_insert(file, values, regex:regex, offset:offset)
          }
        }
      }
    }
  end

  # Test Regex
  #-----------------------------------------------------------------------------
  def test_file_insert_multi_matching_regex_existing_file_with_neg_offset
    values = ['foo1', 'foo2']
    data = ['bar1', 'bar2', 'bar3']
    _data = data * "\n"
    mock = Minitest::Mock.new
    mock.expect(:read, _data)
    mock.expect(:seek, nil, [0])
    mock.expect(:truncate, nil, [0])
    mock.expect(:puts, nil){|x| x == values + data }

    assert(@file_insert_stub[mock, @file, values, regex:/.*bar2.*/, offset:-1])
    assert_mock mock
  end

  def test_file_insert_multi_matching_regex_existing_file_with_zero_offset
    values = ['foo1', 'foo2']
    data = ['bar1', 'bar2', 'bar3']
    _data = data * "\n"
    data.insert(1, values.first)
    data.insert(2, values.last)
    mock = Minitest::Mock.new
    mock.expect(:read, _data)
    mock.expect(:seek, nil, [0])
    mock.expect(:truncate, nil, [0])
    mock.expect(:puts, nil){|x| x == data }

    assert(@file_insert_stub[mock, @file, values, regex:/.*bar2.*/, offset:0])
    assert_mock mock
  end

  def test_file_insert_multi_matching_regex_existing_file_with_pos_offset
    values = ['foo1', 'foo2']
    data = ['bar1', 'bar2', 'bar3']
    _data = data * "\n"
    data.insert(3, values.first)
    data.insert(4, values.last)
    mock = Minitest::Mock.new
    mock.expect(:read, _data)
    mock.expect(:seek, nil, [0])
    mock.expect(:truncate, nil, [0])
    mock.expect(:puts, nil){|x| x == data }

    assert(@file_insert_stub[mock, @file, values, regex:/.*bar2.*/, offset:2])
    assert_mock mock
  end

  def test_file_insert_single_non_matching_regex_existing_file_default_offset
    values = ['foo']
    data = ['bar1', 'bar2', 'bar3']
    mock = Minitest::Mock.new
    mock.expect(:read, data * "\n")

    refute(@file_insert_stub[mock, @file, values, regex:/.*foo2.*/])
    assert_mock mock
  end

  def test_file_insert_multi_matching_regex_existing_file_default_offset
    values = ['foo1', 'foo2']
    data = ['bar1', 'bar2', 'bar3']
    _data = data * "\n"
    data.insert(2, values.first)
    data.insert(3, values.last)
    mock = Minitest::Mock.new
    mock.expect(:read, _data)
    mock.expect(:seek, nil, [0])
    mock.expect(:truncate, nil, [0])
    mock.expect(:puts, nil){|x| x == data }

    assert(@file_insert_stub[mock, @file, values, regex:/.*bar2.*/])
    assert_mock mock
  end

  def test_file_insert_single_matching_regex_existing_file_default_offset
    values = ['foo']
    data = ['bar1', 'bar2', 'bar3']
    _data = data * "\n"
    data.insert(2, values.first)
    mock = Minitest::Mock.new
    mock.expect(:read, _data)
    mock.expect(:seek, nil, [0])
    mock.expect(:truncate, nil, [0])
    mock.expect(:puts, nil){|x| x == data }

    assert(@file_insert_stub[mock, @file, values, regex:/.*bar2.*/])
    assert_mock mock
  end

  # Test Append
  #-----------------------------------------------------------------------------
  def test_file_insert_empty_append
    mock = Minitest::Mock.new

    refute(@file_insert_stub[mock, @file, ""], "No file change should have occurred")
    refute(@file_insert_stub[mock, @file, []], "No file change should have occurred")
    refute(@file_insert_stub[mock, @file, nil], "No file change should have occurred")
    assert_mock mock
  end

  def test_file_insert_single_append_existing_file
    values = ['foo']
    data = ['bar1', 'bar2', 'bar3']
    _data = data * "\n"
    mock = Minitest::Mock.new
    mock.expect(:read, _data)
    mock.expect(:seek, nil, [0])
    mock.expect(:truncate, nil, [0])
    mock.expect(:puts, nil){|x| x == data + values }

    assert(@file_insert_stub[mock, @file, values])
    assert_mock mock
  end

  def test_file_insert_single_append_new_file
    values = ['foo']
    mock = Minitest::Mock.new
    mock.expect(:read, "")
    mock.expect(:seek, nil, [0])
    mock.expect(:truncate, nil, [0])
    mock.expect(:puts, nil){|x| x == values }

    assert(@file_insert_stub[mock, @file, values])
    assert_mock mock
  end

  def test_file_insert_multi_append_existing_file
    values = ['foo1', 'foo2']
    data = ['bar1', 'bar2', 'bar3']
    _data = data * "\n"
    mock = Minitest::Mock.new
    mock.expect(:read, _data)
    mock.expect(:seek, nil, [0])
    mock.expect(:truncate, nil, [0])
    mock.expect(:puts, nil){|x| x == data + values }

    assert(@file_insert_stub[mock, @file, values])
    assert_mock mock
  end

  def test_file_insert_multi_append_new_file
    values = ['foo1', 'foo2']
    mock = Minitest::Mock.new
    mock.expect(:read, "")
    mock.expect(:seek, nil, [0])
    mock.expect(:truncate, nil, [0])
    mock.expect(:puts, nil){|x| x == values }

    assert(@file_insert_stub[mock, @file, values])
    assert_mock mock
  end

  def test_file_insert_rescue
    data = ['bar1', 'bar2', 'bar3']
    mock = Minitest::Mock.new
    mock.expect(:read, data) # passing in wrong type here to make it fail
    mock.expect(:<<, data, [data])

    assert_raises(NoMethodError){@file_insert_stub[mock, @file, ['foo']]}
    assert_mock mock
  end
end

# vim: ft=ruby:ts=2:sw=2:sts=2
