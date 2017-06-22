#!/usr/bin/env ruby
require 'minitest/autorun'
require 'ostruct'

require_relative '../lib/change'

class TestApply < Minitest::Test

  def setup
    @file = 'foo'
    @ctx = OpenStruct.new({root: '/de', vars: {var1: 'var1'}})
  end

  def test_apply_file_doesnt_exist
    change = { 'edit' => 'foo', 'value' => 'bar' }

    FileUtils.stub(:mkdir_p, true, @file){
      File.stub(:exist?, false, @file){
        Change.stub(:insert, true, @file){
          assert(Change.apply(change, @ctx))
        }
      }
    }
  end

#  def test_apply_file_replace_exists_changed
#    change = { 'edit' => 'foo', 'append' => true, 'value' => 'bar' }
#
#    mock = Minitest::Mock.new
#    mock.expect(:=~, false, [Regexp.new(Regexp.quote('foo'))])
#
#    assert_args = ->(file, regex, value){
#      assert_equal(@file, file)
#      assert_equal('', values)
#      assert_equal('', value)
#      true
#    }
#
#    File.stub(:exist?, true, @file){
#      File.stub(:read, mock, @file){
#        Change.stub(:replace, assert_args){
#          assert(Change.apply(change, @ctx))
#        }
#      }
#    }
#
#    assert_mock(mock)
#  end

  def test_apply_file_insert_exists_changed
    change = { 'edit' => 'foo', 'append' => true, 'value' => 'bar' }

    mock = Minitest::Mock.new
    mock.expect(:=~, false, [Regexp.new(Regexp.quote('bar'))])

    assert_args = ->(file, values, opts){
      assert_equal(File.join(@ctx.root, @file), file)
      assert_equal(['bar'], values)
      assert_nil(opts['regex'])
      assert_nil(opts['offset'])
      true
    }

    File.stub(:exist?, true, @file){
      File.stub(:read, mock, @file){
        Change.stub(:insert, assert_args){
          assert(Change.apply(change, @ctx))
        }
      }
    }

    assert_mock(mock)
  end
end

class TestReplace < Minitest::Test

  def setup
    @file = 'foo'
    @vars ||= {'arch' => 'x86_64','release' => '4.7.4-1', 'distro' => 'cyberlinux'}
    @mock = Minitest::Mock.new
    @mock.expect(:seek, nil, [0])
    @mock.expect(:truncate, nil, [0])

    @replace_lam ||= ->(mock, file, regex, value){
      File.stub(:open, true, mock){
        Change.replace(file, regex, value)
      }
    }
  end

  def teardown
    assert_mock(@mock)
  end

  def test_replace_with_regex_comment_multiline
    data = ['UseFooBar=true', 'UncleBob=false']
    _data = ['#UseFooBar=true', '#UncleBob=false']
    @mock.expect(:read, data * "\n")
    @mock.expect(:puts, nil){|x|
      print("Failed puts with: ", x) if x != _data
      x == _data
    }

    # Weird, needs the ^ to not insert # at begining and end
    assert(@replace_lam[@mock, @file, /^(.*)/, '#\1'])
  end

  def test_replace_with_regex_set_value
    data = ['UseFooBar=true', 'UncleBob=false']
    _data = ['UseFooBar=false', 'UncleBob=false']
    @mock.expect(:read, data * "\n")
    @mock.expect(:puts, nil){|x| x == _data }

    assert(@replace_lam[@mock, @file, /(UseFooBar)=.*/, '\1=false'])
  end

  def test_replace_with_regex_uncomment_multiline
    data = ['#UseFooBar=true', '#UncleBob=false']
    _data = ['UseFooBar=true', 'UncleBob=false']
    @mock.expect(:read, data * "\n")
    @mock.expect(:puts, nil){|x| x == _data}

    assert(@replace_lam[@mock, @file, /^#(.*)/, '\1'])
  end

  def test_replace_with_regex_and_remember_change
    data = ['bar1', '<%= distro %>', 'bar3']
    _data = data.clone
    _data[1] = '<%= bar2 %>'
    @mock.expect(:read, data * "\n")
    @mock.expect(:puts, nil){|x| x == _data }

    assert(@replace_lam[@mock, @file, /(.*)distro(.*)/, '\1bar2\2'])
  end

  def test_replace_with_regex_and_no_change
    data = ['bar1', '<%= distro %>', 'bar3']
    _data = data.clone
    @mock.expect(:read, data * "\n")
    @mock.expect(:puts, nil){|x| x == _data }

    refute(@replace_lam[@mock, @file, /(.*)bistro(.*)/, '\1bar2\2'])
  end

  def test_replace_rescue
    data = ['bar1', 'bar2', 'bar3']
    @mock = Minitest::Mock.new
    @mock.expect(:read, nil) # passing in wrong type here to make it fail

    File.stub(:open, true, @mock){
      assert_raises(NoMethodError){Change.replace(@file, /.*foo/, 'foo')}
    }
  end
end

class TestResolve < Minitest::Test

  def setup
    @vars ||= {'arch' => 'x86_64','release' => '4.7.4-1', 'distro' => 'cyberlinux'}
    @mock = Minitest::Mock.new
    @mock.expect(:seek, nil, [0])
    @mock.expect(:truncate, nil, [0])

    @resolve_lam ||= ->(mock, file, vars){
      File.stub(:open, true, mock){
        Change.resolve(file, vars)
      }
    }
  end

  def teardown
    assert_mock(@mock)
  end

  def test_resolve_missing_var
    data = "bar1\n<%= bar %>\nbar3"
    @mock = Minitest::Mock.new
    @mock.expect(:read, data)
    @mock.expect(:<<, data, [data])

    File.stub(:open, true, @mock){
      assert_raises(NameError){Change.resolve('foo', @vars)}
    }
  end

  def test_resolve_with_change
    data = "bar1\n<%= distro %>\nbar3"
    _data = "bar1\ncyberlinux\nbar3"
    @mock.expect(:read, data)
    @mock.expect(:puts, nil){|x| x == _data }

    assert(@resolve_lam[@mock, 'foo', @vars])
  end

  def test_resolve_with_single_file_and_no_change
    data = "bar1\nbar2\nbar3"
    @mock = Minitest::Mock.new
    @mock.expect(:read, data)

    refute(@resolve_lam[@mock, 'foo', @vars])
  end
end

class TestFileInsert < Minitest::Test

  def setup
    @file ||= 'foo'
    @mock = Minitest::Mock.new
    @mock.expect(:seek, nil, [0])
    @mock.expect(:truncate, nil, [0])

    @insert_lam ||= ->(mock, file, values, regex:nil, offset:1){
      FileUtils.stub(:touch, true, file){
        File.stub(:exist?, false, file){
          File.stub(:open, true, mock){
            Change.insert(file, values, regex:regex, offset:offset)
          }
        }
      }
    }
  end

  def teardown
    assert_mock(@mock)
  end

  # Test Regex
  #-----------------------------------------------------------------------------
  def test_insert_multi_matching_regex_existing_file_with_neg_offset
    values = ['foo1', 'foo2']
    data = ['bar1', 'bar2', 'bar3']
    _data = data * "\n"
    @mock.expect(:read, _data)
    @mock.expect(:puts, nil){|x| x == values + data }

    assert(@insert_lam[@mock, @file, values, regex:/.*bar2.*/, offset:-1])
  end

  def test_insert_multi_matching_regex_existing_file_with_zero_offset
    values = ['foo1', 'foo2']
    data = ['bar1', 'bar2', 'bar3']
    _data = data * "\n"
    data.insert(1, values.first)
    data.insert(2, values.last)
    @mock.expect(:read, _data)
    @mock.expect(:puts, nil){|x| x == data }

    assert(@insert_lam[@mock, @file, values, regex:/.*bar2.*/, offset:0])
  end

  def test_insert_multi_matching_regex_existing_file_with_pos_offset
    values = ['foo1', 'foo2']
    data = ['bar1', 'bar2', 'bar3']
    _data = data * "\n"
    data.insert(3, values.first)
    data.insert(4, values.last)
    @mock.expect(:read, _data)
    @mock.expect(:puts, nil){|x| x == data }

    assert(@insert_lam[@mock, @file, values, regex:/.*bar2.*/, offset:2])
  end

  def test_insert_single_non_matching_regex_existing_file_default_offset
    values = ['foo']
    data = ['bar1', 'bar2', 'bar3']
    @mock = Minitest::Mock.new
    @mock.expect(:read, data * "\n")

    refute(@insert_lam[@mock, @file, values, regex:/.*foo2.*/])
  end

  def test_insert_multi_matching_regex_existing_file_default_offset
    values = ['foo1', 'foo2']
    data = ['bar1', 'bar2', 'bar3']
    _data = data * "\n"
    data.insert(2, values.first)
    data.insert(3, values.last)
    @mock.expect(:read, _data)
    @mock.expect(:puts, nil){|x| x == data }

    assert(@insert_lam[@mock, @file, values, regex:/.*bar2.*/])
  end

  def test_insert_single_matching_regex_existing_file_default_offset
    values = ['foo']
    data = ['bar1', 'bar2', 'bar3']
    _data = data * "\n"
    data.insert(2, values.first)
    @mock.expect(:read, _data)
    @mock.expect(:puts, nil){|x| x == data }

    assert(@insert_lam[@mock, @file, values, regex:/.*bar2.*/])
  end

  # Test Append
  #-----------------------------------------------------------------------------
  def test_insert_empty_append
    @mock = Minitest::Mock.new

    refute(@insert_lam[@mock, @file, ""], "No file change should have occurred")
    refute(@insert_lam[@mock, @file, []], "No file change should have occurred")
    refute(@insert_lam[@mock, @file, nil], "No file change should have occurred")
  end

  def test_insert_single_append_existing_file
    values = ['foo']
    data = ['bar1', 'bar2', 'bar3']
    _data = data * "\n"
    @mock.expect(:read, _data)
    @mock.expect(:puts, nil){|x| x == data + values }

    assert(@insert_lam[@mock, @file, values])
  end

  def test_insert_single_append_new_file_nil_offset
    values = ['foo']
    @mock.expect(:read, "")
    @mock.expect(:puts, nil){|x| x == values }

    assert(@insert_lam[@mock, @file, values, offset:nil])
  end

  def test_insert_single_append_new_file
    values = ['foo']
    @mock.expect(:read, "")
    @mock.expect(:puts, nil){|x| x == values }

    assert(@insert_lam[@mock, @file, values])
  end

  def test_insert_multi_append_existing_file
    values = ['foo1', 'foo2']
    data = ['bar1', 'bar2', 'bar3']
    _data = data * "\n"
    @mock.expect(:read, _data)
    @mock.expect(:puts, nil){|x| x == data + values }

    assert(@insert_lam[@mock, @file, values])
  end

  def test_insert_multi_append_new_file
    values = ['foo1', 'foo2']
    @mock.expect(:read, "")
    @mock.expect(:puts, nil){|x| x == values }

    assert(@insert_lam[@mock, @file, values])
  end

  def test_insert_rescue
    data = ['bar1', 'bar2', 'bar3']
    @mock = Minitest::Mock.new
    @mock.expect(:read, data) # passing in wrong type here to make it fail
    @mock.expect(:<<, data, [data])

    assert_raises(NoMethodError){@insert_lam[@mock, @file, ['foo']]}
  end
end

# vim: ft=ruby:ts=2:sw=2:sts=2
