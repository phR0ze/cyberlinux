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

#-------------------------------------------------------------------------------
# Maintainer: phR0ze
#-------------------------------------------------------------------------------
pkgname=(
    'cyberlinux-config'           # core
    'cyberlinux-shell-config'     # shell
    'cyberlinux-lite-config'      # lite
    'cyberlinux-server-config'    # server
    'cyberlinux-netbook-config'   # netbook
    'cyberlinux-theater-config'   # theater
    'cyberlinux-desktop-config'   # shell
    'cyberlinux-laptop-config'    # laptop
)
pkgver=0.0.4
pkgrel=1
pkgdesc='Configuration files for cyberlinux'
arch=('any')
url="https://github.com/phR0ze/cyberlinux/aur/cyberlinux-config"
license=('MIT')

pkg() {
  local name=$1
  shopt -s dotglob
  shopt -s extglob
  pkgdesc="Configuration for the cyberlinux ${name} deployment"

  cd $srcdir/../config/$name

  # Install config files
  while IFS='' read -r -d '' x; do
    msg2 "Installing $x"
    mkdir -p "$pkgdir/$(dirname $x)"
    cp -dr "$x" "$pkgdir/$x"
  done < <(find . -type f -print0 -o -type l -print0)
}

package_cyberlinux-config()
{
  pkg core
}

package_cyberlinux-shell-config()
{
  depends=('cyberlinux-config')
  pkg shell
}

package_cyberlinux-lite-config()
{
  depends=('cyberlinux-shell-config')
  pkg lite
}

package_cyberlinux-server-config()
{
  depends=('cyberlinux-lite-config')
  conflicts=('cyberlinux-desktop-config' 'cyberlinux-laptop-config' 'cyberlinux-netbook-config' 'cyberlinux-theater-config')
  pkg lite
}

package_cyberlinux-theater-config()
{
  depends=('cyberlinux-lite-config')
  conflicts=('cyberlinux-desktop-config' 'cyberlinux-laptop-config' 'cyberlinux-netbook-config' 'cyberlinux-server-config')
  pkg theater
}

package_cyberlinux-netbook-config()
{
  depends=('cyberlinux-lite-config')
  conflicts=('cyberlinux-desktop-config' 'cyberlinux-laptop-config' 'cyberlinux-server-config' 'cyberlinux-theater-config')
  pkg netbook
}

package_cyberlinux-desktop-config()
{
  depends=('cyberlinux-lite-config')
  conflicts=('cyberlinux-server-config' 'cyberlinux-laptop-config' 'cyberlinux-netbook-config' 'cyberlinux-theater-config')
  install=desktop.install
  pkg desktop
}

package_cyberlinux-laptop-config()
{
  depends=('cyberlinux-lite-config')
  conflicts=('cyberlinux-desktop-config' 'cyberlinux-server-config' 'cyberlinux-netbook-config' 'cyberlinux-theater-config')
  pkg laptop
}
