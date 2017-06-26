#!/usr/bin/env ruby
require 'erb'

# Creates an isolated ERB variable context easily from a hash
# +hash+:: variables to use for ERB context
class ERBContext
  def initialize(hash)
    hash.each{|k,v| singleton_class.send(:define_method, k){ v }}
  end

  def get_binding
    binding
  end
end

# Resolve variables for the given data type
# Params:
# +vars+:: hash or OpenStruct of ERB variables to use
# +die+:: when false don't fail when missing variables
class ERBResolve
  def initialize(vars)
    raise ArgumentError.new("Variables are required") if not vars

    @vars = vars.is_a?(OpenStruct) ? vars.to_h : vars
    @context = ERBContext.new(@vars).get_binding
  end

  # Resolve variables for the given data type
  # +data+:: data to replace vars in (string, array, or hash)
  # +returns+:: mutated data structure
  def resolve(data)

    # Recurse
    if data.is_a?(Array)
      data = data.map{|x| resolve(x)}
    elsif data.is_a?(Hash)
      data.each{|k,v| data[k] = resolve(v)}
    end

    # Base case
    if data.is_a?(String)
      data = ERB.new(data).result(@context)
    end

    return data
  end
end

# String extension to easily inject ERB variables into a string
# +vars+:: hash of variables to inject into the string
class ::String
  def erb(vars = {})
    ERBResolve.new(vars).resolve(self)
  end
end

# Hash extension to easily inject ERB variables into hash values
# +vars+:: hash of variables to inject into the string
class ::Hash
  def erb(vars = {})
    ERBResolve.new(vars).resolve(self)
  end
end

# Array extension to easily inject ERB variables into Array values
# +vars+:: hash of variables to inject into the string
class ::Array
  def erb(vars = {})
    ERBResolve.new(vars).resolve(self)
  end
end

# vim: ft=ruby:ts=2:sw=2:sts=2
