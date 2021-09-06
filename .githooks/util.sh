#!/usr/bin/env bash
#MIT License
#Copyright (c) 2019-2021 phR0ze
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

# Read target file and capture Sem Version string and set result
get_version() {
  local file="$1"     # target version file to read from
  local regex="$2"    # version regex to use when looking for version
  local result=$3     # captured version set as result

  # If target exists read line by line and check for match
  if [ -f "$file" ]; then

    # IFS= prevents leading/trailing whitespace from being ignored
    # -r prevents backslash escapes from being interpreted
    # || [[ -n $line ]] prevents the last line from being ignored if it doesn't end with a \n
    while IFS= read -r line || [[ -n "$line" ]]; do
      if [[ "$line" =~ $regex ]]; then
        eval $result="'${BASH_REMATCH[1]}'"
        break
      fi
    done < "$file"
  fi
}

# Read commit message and prepend version if it doesn't exist
prepend_version(){
  local msg=$(<$1)    # read in the message file
  local regex="$2"    # regex to use to detect version in message
  local ver="$3"      # version to use when prepending to message

  # Don't modify the message if a version wasn't given
  if [[ "x$ver" != "x" ]]; then

    # Prepend the version to the message if no version is present
    if ! [[ "$msg" =~ $regex ]]; then
      echo "$ver: $msg" > $1
    else

      # Replace the pepended message version if version present
      echo "$ver: ${BASH_REMATCH[1]}" > $1
    fi
  fi
}

# Update copyright in changed ASCII files
update_copyright() {
  local copyright="$1"        # regex escaped string to use for copyright pattern
  local year=$(date +"%Y")    # current year to use for copyright updates

  files=$(git diff --cached --name-only --diff-filter=d)
  for x in $files; do

    # Only update copyright if its an ASCII file
    if [[ "$(file $x)" == *"ASCII text"* ]]; then
      local updated=
      local original=

      # Check copyright and update if required
      while IFS= read -r line || [[ -n "$line" ]]; do

        # Handle year range
        local regex="(.*$copyright)[[:space:]]*([0-9]{4})-([0-9]{4})(.*)"
        if [[ "$line" =~ $regex ]]; then
          if [ "${BASH_REMATCH[3]}" != "$year" ]; then
            updated="${BASH_REMATCH[1]} ${BASH_REMATCH[2]}-${year}${BASH_REMATCH[4]}"
            original="$line"
          fi
          break
        fi

        # Handle single year
        local regex="(.*$copyright)[[:space:]]*([0-9]{4})(.*)"
        if [[ "$line" =~ $regex ]]; then
          if [ "${BASH_REMATCH[2]}" != "$year" ]; then
            updated="${BASH_REMATCH[1]} ${BASH_REMATCH[2]}-${year}${BASH_REMATCH[3]}"
            original="$line"
          fi
          break
        fi
      done < "$x"

      # Update target file
      if [ "x$updated" != "x" ]; then
        sed -i -e "s/$original/$updated/" "$x"
        git add "$x"
      fi
    fi
  done
}

# Increment the revision of the semantic version
increment_version() {
  local file="$1"     # target version file to read from
  local regex="$2"    # regex for version must include before and after pieces

  # If target exists read line by line and check for match
  if [ -f "$file" ]; then
    local original=     # original line

    # Capture version
    while IFS= read -r line || [[ -n "$line" ]]; do
      if [[ "$line" =~ $regex ]]; then
        original="$line"
        break
      fi
    done < "$file"

    # Increment the revision portion of the version
    IFS=. read major minor rev <<< ${BASH_REMATCH[2]}
    ((rev++))
    ver="$major.$minor.$rev"
    updated="${BASH_REMATCH[1]}$ver${BASH_REMATCH[3]}"

    # Write out the changes to the file and stage
    sed -i -e "s/$original/$updated/" "$file"
    git add "$file"
    echo "Version: $ver $(basename ${file})"
  fi
}

# vim: ts=2:sw=2:sts=2
