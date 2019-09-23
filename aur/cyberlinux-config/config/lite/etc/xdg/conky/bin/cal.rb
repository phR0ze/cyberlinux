#!/usr/bin/env ruby
#MIT License
#Copyright (c) 2017-2019 phR0ze
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
require 'date'

spaces = ARGV.first.to_i  # Number of spaces to use between days
offset = ARGV.last        # Number of offset spaces for line

# Generate array of days with first of the month spacing
# [' ', '1', '2', '3', ... , '31'] 
now = Date.today
prefix = Date.new(now.year, now.month, 1).wday.to_i
end_of_month = Date.new(now.year, now.month, -1).day
[*1..end_of_month].unshift(*[* [' '] * prefix]).each_slice(7){|wk|
  print("${offset #{offset}}") if ARGV.size > 1
  wk.each{|day|
    print("#{' ' * spaces}")
    print("${color2}") if day == now.day
    print("#{day.to_s.rjust(2)}")
    print("${color1}") if day == now.day
  }
  puts
}
# vim: ft=ruby:ts=2:sw=2:sts=2
