#!/usr/bin/env ruby
#MIT License
#Copyright (c) 2017 phR0ze
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.

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

# String extensions
class ::String

  # Easily inject ERB variables into a string
  # +vars+:: hash of variables to inject into the string
  def erb(vars = {})
    ERBResolve.new(vars).resolve(self)
  end
end

# Hash extensions
class ::Hash

  # Do a deep copy on the object
  def clone
    hash = {}
    self.each{|k, v| hash[k] = v.clone }
    return hash
  end

  # Easily inject ERB variables into hash values
  # +vars+:: hash of variables to inject into the string
  def erb(vars = {})
    ERBResolve.new(vars).resolve(self)
  end
end

# Array extensions
class ::Array

  # Do a deep copy on the object
  def clone
    return self.map{|x| x.clone }
  end

  # Easily inject ERB variables into Array values
  # +vars+:: hash of variables to inject into the string
  def erb(vars = {})
    ERBResolve.new(vars).resolve(self)
  end
end

# vim: ft=ruby:ts=2:sw=2:sts=2
