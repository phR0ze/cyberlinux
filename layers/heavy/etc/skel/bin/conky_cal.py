#!/usr/bin/env python
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

import sys, time, re, calendar
 
# Number of spaces to use is the only param passed in
spaces = int(sys.argv[1])

# Configure calendar
localtime = time.localtime(time.time())
calendar.setfirstweekday(calendar.SUNDAY)
day = str(localtime[2]).rjust(2)
cal = calendar.month(localtime[0], localtime[1])

# Print out a simple calendar for conky
cal = "\n".join(["%s%s" % (''.rjust(spaces), x) for x in cal.split("\n")[2:-1]])
cal = re.sub('(\d\d )', '\g<1> ', cal)
cal = re.sub('( \d )', '\g<1> ', cal)
cal = cal.split("\n")
cal[0] = cal[0].strip().rjust(26 + spaces)
cal = "\n".join(cal)
cal = re.sub(day, '${color2}%s${color1}' % day, cal)
print(cal),
