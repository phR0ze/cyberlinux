#!/usr/bin/env ruby
require_relative '../reduce'
require_relative '../lib/erb'
require 'erb'
require 'minitest/autorun'
require 'ostruct'
require 'yaml'

# References
#-------------------------------------------------------------------------------
# http://docs.seattlerb.org/minitest/Minitest/Assertions.html
# https://github.com/seattlerb/minitest/blob/master/lib/minitest/mock.rb
#-------------------------------------------------------------------------------
class TestResolveTemplates < Minitest::Test

  def setup
    @reduce ||= Reduce.new
    @k ||= @reduce.instance_variable_get(:@k)
    @vars ||= {'arch' => 'x86_64','release' => '4.7.4-1', 'distro' => 'cyberlinux'}

    @resolve_templates_stub ||= ->(mock, file, vars){
      File.stub(:open, true, mock){
        @reduce.stub(:puts, nil){
          @reduce.stub(:print, nil){
            @reduce.resolve_templates(file, vars)
          }
        }
      }
    }
  end

  def test_resolve_templates_missing_var
    data = "bar1\n<%= bar %>\nbar3"
    mock = Minitest::Mock.new
    mock.expect(:read, data)
    mock.expect(:<<, data, [data])

    assert_raises(NameError){@resolve_templates_stub[mock, 'foo', @vars]}
    assert_mock mock
  end

  def test_resolve_templates_with_single_file_and_change
    data = "bar1\n<%= distro %>\nbar3"
    _data = "bar1\ncyberlinux\nbar3"
    mock = Minitest::Mock.new
    mock.expect(:read, data)
    mock.expect(:seek, nil, [0])
    mock.expect(:truncate, nil, [0])
    mock.expect(:puts, nil){|x| x == _data }

    assert(@resolve_templates_stub[mock, 'foo', @vars])
    assert_mock mock
  end

  def test_resolve_templates_with_single_file_and_no_change
    data = "bar1\nbar2\nbar3"
    mock = Minitest::Mock.new
    mock.expect(:read, data)

    refute(@resolve_templates_stub[mock, 'foo', @vars])
    assert_mock mock
  end

  def test_resolve_templates_with_multiple_files_and_change
    data1 = "bar1\n<%= distro %>\nbar3"
    _data1 = "bar1\ncyberlinux\nbar3"
    data2 = "bar1\n<%= arch %>\nbar3"
    _data2 = "bar1\nx86_64\nbar3"
    mock = Minitest::Mock.new
    mock.expect(:read, data1)
    mock.expect(:read, data2)
    mock.expect(:seek, nil, [0])
    mock.expect(:seek, nil, [0])
    mock.expect(:truncate, nil, [0])
    mock.expect(:truncate, nil, [0])
    mock.expect(:puts, nil){|x| x == _data1 }
    mock.expect(:puts, nil){|x| x == _data2 }

    assert(@resolve_templates_stub[mock, ['foo1', 'foo2'], @vars])
    assert_mock mock
  end
end


class TestErb < Minitest::Test

  def setup
    @reduce ||= Reduce.new
    @k ||= @reduce.instance_variable_get(:@k)
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

class TestGetLayers < Minitest::Test

  def setup
    @reduce ||= Reduce.new
    @k = @reduce.instance_variable_get(:@k)
  end

  def test_getlayers_with_bad_layer_name
    refute(@reduce.getlayers('foo'))
  end

  def test_getlayers_with_good_layer_name_expecting_single_result
    yml = @reduce.getlayers(@k.base)
    assert(yml)
    assert_equal(yml.size, 1)
    assert_equal(yml.first, @k.base)
  end

  def test_getlayers_with_good_layer_name_expecting_multi_result
    yml = @reduce.getlayers('heavy')
    assert(yml)
    assert_equal(yml.size, 4)
    assert_equal(yml, ['heavy', 'lite', 'shell', 'base'])
  end
end

class TestGetLayer < Minitest::Test

  def setup
    @reduce ||= Reduce.new
    @k = @reduce.instance_variable_get(:@k)
  end

  def test_getlayer_with_bad_layer_name
    refute(@reduce.getlayer('foo'))
  end

  def test_getlayer_build
    yml = @reduce.getlayer(@k.build)
    assert(yml)
    assert_equal(yml[@k.layer], @k.build)
  end

  def test_getlayer_with_good_layer_name
    yml = @reduce.getlayer(@k.base)
    assert(yml)
    assert_equal(yml[@k.layer], @k.base)
  end
end

class TestFileInsert < Minitest::Test

  def setup
    @file ||= 'foo'
    @reduce ||= Reduce.new

    @file_insert_stub ||= ->(mock, file, values, regex:nil, offset:1){
      FileUtils.stub(:touch, true, file){
        File.stub(:exist?, false, file){
          File.stub(:open, true, mock){
            @reduce.file_insert(file, values, regex:regex, offset:offset)
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
