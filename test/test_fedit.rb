#!/usr/bin/env ruby
#require 'mocha/mini_test'
require 'minitest/autorun'
require 'ostruct'

require_relative '../lib/fedit'

# References
# http://gofreerange.com/mocha/docs/
#-------------------------------------------------------------------------------

#class TestFileEdit < Minitest::Test
#
#  def setup
#    @file = 'foo'
#  end
#
#  def test_file_edit_file_doesnt_exist
#    change = { 'value' => 'foo' }
#    
#    #Object.stubs(:file_insert).returns(false)
#    FileUtils.stubs(:mkdir_p).with(@file).returns(true)
#    FileUtils.stubs(:mkdir_p).with(@file).returns(true)
#    #refute(file_edit(change, @file))
#    #Object.any_instance.stubs(:file_insert).returns(false).then.returns(true)
#
#    #FileUtils.stub(:mkdir_p, true, @file){
#    #  File.stub(:exist?, false, @file){
#    #    Object.stub(:file_insert, true, @file){
#    #      refute(file_edit(change, @file))
#    #    }
#    #  }
#    #}
#  end
#end

class TestFileReplace < Minitest::Test

  def setup
    @file = 'foo'
    @vars ||= {'arch' => 'x86_64','release' => '4.7.4-1', 'distro' => 'cyberlinux'}
    @mock = Minitest::Mock.new
    @mock.expect(:seek, nil, [0])
    @mock.expect(:truncate, nil, [0])

    @file_replace_stub ||= ->(mock, file, regex, value){
      File.stub(:open, true, mock){
        file_replace(file, regex, value)
      }
    }
  end

  def teardown
    assert_mock @mock
  end

  def test_file_replace_with_regex_comment_multiline
    data = ['UseFooBar=true', 'UncleBob=false']
    _data = ['#UseFooBar=true', '#UncleBob=false']
    @mock.expect(:read, data * "\n")
    @mock.expect(:puts, nil){|x|
      print("Failed puts with: ", x) if x != _data
      x == _data
    }

    # Weird, needs the ^ to not insert # at begining and end
    assert(@file_replace_stub[@mock, @file, /^(.*)/, '#\1'])
  end

  def test_file_replace_with_regex_set_value
    data = ['UseFooBar=true', 'UncleBob=false']
    _data = ['UseFooBar=false', 'UncleBob=false']
    @mock.expect(:read, data * "\n")
    @mock.expect(:puts, nil){|x| x == _data }

    assert(@file_replace_stub[@mock, @file, /(UseFooBar)=.*/, '\1=false'])
  end

  def test_file_replace_with_regex_uncomment_multiline
    data = ['#UseFooBar=true', '#UncleBob=false']
    _data = ['UseFooBar=true', 'UncleBob=false']
    @mock.expect(:read, data * "\n")
    @mock.expect(:puts, nil){|x| x == _data}

    assert(@file_replace_stub[@mock, @file, /^#(.*)/, '\1'])
  end

  def test_file_replace_with_regex_and_remember_change
    data = ['bar1', '<%= distro %>', 'bar3']
    _data = data.clone
    _data[1] = '<%= bar2 %>'
    @mock.expect(:read, data * "\n")
    @mock.expect(:puts, nil){|x| x == _data }

    assert(@file_replace_stub[@mock, @file, /(.*)distro(.*)/, '\1bar2\2'])
  end

  def test_file_replace_with_regex_and_no_change
    data = ['bar1', '<%= distro %>', 'bar3']
    _data = data.clone
    @mock.expect(:read, data * "\n")
    @mock.expect(:puts, nil){|x| x == _data }

    refute(@file_replace_stub[@mock, @file, /(.*)bistro(.*)/, '\1bar2\2'])
  end

  def test_file_replace_rescue
    data = ['bar1', 'bar2', 'bar3']
    @mock = Minitest::Mock.new
    @mock.expect(:read, nil) # passing in wrong type here to make it fail

    File.stub(:open, true, @mock){
      assert_raises(NoMethodError){file_replace(@file, /.*foo/, 'foo')}
    }
  end
end

class TestResolveTemplate < Minitest::Test

  def setup
    @vars ||= {'arch' => 'x86_64','release' => '4.7.4-1', 'distro' => 'cyberlinux'}
    @mock = Minitest::Mock.new
    @mock.expect(:seek, nil, [0])
    @mock.expect(:truncate, nil, [0])

    @resolve_template_stub ||= ->(mock, file, vars){
      File.stub(:open, true, mock){
        resolve_template(file, vars)
      }
    }
  end

  def teardown
    assert_mock @mock
  end

  def test_resolve_template_missing_var
    data = "bar1\n<%= bar %>\nbar3"
    @mock = Minitest::Mock.new
    @mock.expect(:read, data)
    @mock.expect(:<<, data, [data])

    File.stub(:open, true, @mock){
      assert_raises(NameError){resolve_template('foo', @vars)}
    }
  end

  def test_resolve_template_with_change
    data = "bar1\n<%= distro %>\nbar3"
    _data = "bar1\ncyberlinux\nbar3"
    @mock.expect(:read, data)
    @mock.expect(:puts, nil){|x| x == _data }

    assert(@resolve_template_stub[@mock, 'foo', @vars])
  end

  def test_resolve_template_with_single_file_and_no_change
    data = "bar1\nbar2\nbar3"
    @mock = Minitest::Mock.new
    @mock.expect(:read, data)

    refute(@resolve_template_stub[@mock, 'foo', @vars])
  end
end

class TestFileInsert < Minitest::Test

  def setup
    @file ||= 'foo'
    @mock = Minitest::Mock.new
    @mock.expect(:seek, nil, [0])
    @mock.expect(:truncate, nil, [0])

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

  def teardown
    assert_mock @mock
  end

  # Test Regex
  #-----------------------------------------------------------------------------
  def test_file_insert_multi_matching_regex_existing_file_with_neg_offset
    values = ['foo1', 'foo2']
    data = ['bar1', 'bar2', 'bar3']
    _data = data * "\n"
    @mock.expect(:read, _data)
    @mock.expect(:puts, nil){|x| x == values + data }

    assert(@file_insert_stub[@mock, @file, values, regex:/.*bar2.*/, offset:-1])
  end

  def test_file_insert_multi_matching_regex_existing_file_with_zero_offset
    values = ['foo1', 'foo2']
    data = ['bar1', 'bar2', 'bar3']
    _data = data * "\n"
    data.insert(1, values.first)
    data.insert(2, values.last)
    @mock.expect(:read, _data)
    @mock.expect(:puts, nil){|x| x == data }

    assert(@file_insert_stub[@mock, @file, values, regex:/.*bar2.*/, offset:0])
  end

  def test_file_insert_multi_matching_regex_existing_file_with_pos_offset
    values = ['foo1', 'foo2']
    data = ['bar1', 'bar2', 'bar3']
    _data = data * "\n"
    data.insert(3, values.first)
    data.insert(4, values.last)
    @mock.expect(:read, _data)
    @mock.expect(:puts, nil){|x| x == data }

    assert(@file_insert_stub[@mock, @file, values, regex:/.*bar2.*/, offset:2])
  end

  def test_file_insert_single_non_matching_regex_existing_file_default_offset
    values = ['foo']
    data = ['bar1', 'bar2', 'bar3']
    @mock = Minitest::Mock.new
    @mock.expect(:read, data * "\n")

    refute(@file_insert_stub[@mock, @file, values, regex:/.*foo2.*/])
  end

  def test_file_insert_multi_matching_regex_existing_file_default_offset
    values = ['foo1', 'foo2']
    data = ['bar1', 'bar2', 'bar3']
    _data = data * "\n"
    data.insert(2, values.first)
    data.insert(3, values.last)
    @mock.expect(:read, _data)
    @mock.expect(:puts, nil){|x| x == data }

    assert(@file_insert_stub[@mock, @file, values, regex:/.*bar2.*/])
  end

  def test_file_insert_single_matching_regex_existing_file_default_offset
    values = ['foo']
    data = ['bar1', 'bar2', 'bar3']
    _data = data * "\n"
    data.insert(2, values.first)
    @mock.expect(:read, _data)
    @mock.expect(:puts, nil){|x| x == data }

    assert(@file_insert_stub[@mock, @file, values, regex:/.*bar2.*/])
  end

  # Test Append
  #-----------------------------------------------------------------------------
  def test_file_insert_empty_append
    @mock = Minitest::Mock.new

    refute(@file_insert_stub[@mock, @file, ""], "No file change should have occurred")
    refute(@file_insert_stub[@mock, @file, []], "No file change should have occurred")
    refute(@file_insert_stub[@mock, @file, nil], "No file change should have occurred")
  end

  def test_file_insert_single_append_existing_file
    values = ['foo']
    data = ['bar1', 'bar2', 'bar3']
    _data = data * "\n"
    @mock.expect(:read, _data)
    @mock.expect(:puts, nil){|x| x == data + values }

    assert(@file_insert_stub[@mock, @file, values])
  end

  def test_file_insert_single_append_new_file
    values = ['foo']
    @mock.expect(:read, "")
    @mock.expect(:puts, nil){|x| x == values }

    assert(@file_insert_stub[@mock, @file, values])
  end

  def test_file_insert_multi_append_existing_file
    values = ['foo1', 'foo2']
    data = ['bar1', 'bar2', 'bar3']
    _data = data * "\n"
    @mock.expect(:read, _data)
    @mock.expect(:puts, nil){|x| x == data + values }

    assert(@file_insert_stub[@mock, @file, values])
  end

  def test_file_insert_multi_append_new_file
    values = ['foo1', 'foo2']
    @mock.expect(:read, "")
    @mock.expect(:puts, nil){|x| x == values }

    assert(@file_insert_stub[@mock, @file, values])
  end

  def test_file_insert_rescue
    data = ['bar1', 'bar2', 'bar3']
    @mock = Minitest::Mock.new
    @mock.expect(:read, data) # passing in wrong type here to make it fail
    @mock.expect(:<<, data, [data])

    assert_raises(NoMethodError){@file_insert_stub[@mock, @file, ['foo']]}
  end
end

# vim: ft=ruby:ts=2:sw=2:sts=2
