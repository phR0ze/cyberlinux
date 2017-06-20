#!/usr/bin/env ruby
require 'minitest/autorun'

require_relative '../reduce'

#    @resolve_templates_stub ||= ->(mock, file, vars){
#      File.stub(:open, true, mock){
#        @reduce.stub(:puts, nil){
#          @reduce.stub(:print, nil){
#            @reduce.resolve_templates(file, vars)
#          }
#        }
#      }
#    }

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

# vim: ft=ruby:ts=2:sw=2:sts=2
