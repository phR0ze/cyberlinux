#!/usr/bin/env ruby
#MIT License
#Copyright (c) 2017-2018 phR0ze
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

require 'nub'
require 'minitest/autorun'
require 'ostruct'

require_relative '../lib/config'

class TestApply < Minitest::Test

  def setup
    @file = 'foo'
    @ctx = OpenStruct.new({
      root: '/de',
      vars: {
        var1: 'var1',
        distro: 'foobar',
        file_var: '/foo'
      },
      configs: {
        'config-foobar1' => [
          { 'edit' => '/foo', 'insert' => 'after', 'value' => 'bar', 'regex' => '/bob/' },
        ],
        'config-foobar2' => [
          { 'edit' => '<%= file_var %>', 'insert' => 'after', 'value' => 'bar', 'regex' => '/bob/' }
        ]
      }
    })
  end

  def test_apply_with_exec
    ctx = OpenStruct.new({ root: '.', vars: { var1: 'var1', file_var: '/foo' } })

    Sys.stub(:puts, nil){
      refute(Config.apply({'exec' => 'touch /foo'}, ctx))
      assert(File.exist?('foo'))
      refute(Config.apply({'exec' => 'rm /foo'}, ctx))
      refute(File.exist?('foo'))
    }
  end

  def test_with_templating_reference
    config = @ctx.configs['config-foobar2']
    config_insert_helper(config, 1)
  end

  def test_apply_with_templating
    config = { 'edit' => '<%= file_var %>', 'insert' => 'after', 'value' => 'bar', 'regex' => '/bob/' }
    config_insert_helper(config, 1)
  end

  def test_apply_with_resolve
    config = { 'resolve' => '/foo' }

    assert_args = ->(file, vars){
      assert_equal(File.join(@ctx.root, @file), file)
      assert_equal(@ctx.vars, vars)
      true
    }

    FileUtils.stub(:resolve, assert_args){
      assert(Config.apply(config, @ctx))
    }
  end

  def test_with_reference_success
    config = @ctx.configs['config-foobar1']
    config_insert_helper(config, 1)
  end

  def test_apply_file_doesnt_exist
    config = { 'edit' => '/foo', 'value' => 'bar' }

    Config.stub(:puts, nil){
      FileUtils.stub(:mkdir_p, true, @file){
        File.stub(:exist?, false, @file){
          FileUtils.stub(:insert, true, @file){
            assert(Config.apply(config, @ctx))
          }
        }
      }
    }
  end

  def test_apply_replace
    config = { 'edit' => '/foo', 'regex' => '/bob/', 'value' => 'bar' }

    mock = Minitest::Mock.new
    mock.expect(:=~, false, [Regexp.new(Regexp.quote('bar'))])

    assert_args = ->(file, regex, value){
      assert_equal(File.join(@ctx.root, @file), file)
      assert_equal('/bob/', regex)
      assert_equal('bar', value)
      true
    }

    Config.stub(:puts, nil){
      File.stub(:exist?, true, @file){
        File.stub(:binread, mock, @file){
          FileUtils.stub(:replace, assert_args){
            assert(Config.apply(config, @ctx))
          }
        }
      }
    }

    assert_mock(mock)
  end

  def config_insert_helper(config, offset)
    mock = Minitest::Mock.new
    mock.expect(:=~, false, [Regexp.new(Regexp.quote('bar'))])

    assert_args = ->(file, values, opts){
      assert_equal(File.join(@ctx.root, @file), file)
      assert_equal(['bar'], values)
      assert_equal('/bob/', opts[:regex])
      opts[:offset] ? assert_equal(offset, opts[:offset]) : assert_nil(opts[:offset])
      true
    }

    Config.stub(:puts, nil){
      File.stub(:exist?, true, @file){
        File.stub(:binread, mock, @file){
          FileUtils.stub(:insert, assert_args){
            assert(Config.apply(config, @ctx))
          }
        }
      }
    }

    assert_mock(mock)
  end

  def test_apply_insert
    config = { 'edit' => '/foo', 'insert' => 'after', 'value' => 'bar', 'regex' => '/bob/' }
    config_insert_helper(config, 1)
    config['insert'] = 'before'
    config_insert_helper(config, 0)
    config['insert'] = 'append'
    config_insert_helper(config, nil)
  end

  def test_apply_insert_append
    config = { 'edit' => '/foo', 'insert' => 'append', 'value' => 'bar' }

    mock = Minitest::Mock.new
    mock.expect(:=~, false, [Regexp.new(Regexp.quote('bar'))])

    assert_args = ->(file, values, opts){
      assert_equal(File.join(@ctx.root, @file), file)
      assert_equal(['bar'], values)
      assert_nil(opts[:regex])
      assert_nil(opts[:offset])
      true
    }

    Config.stub(:puts, nil){
      File.stub(:exist?, true, @file){
        File.stub(:binread, mock, @file){
          FileUtils.stub(:insert, assert_args){
            assert(Config.apply(config, @ctx))
          }
        }
      }
    }

    assert_mock(mock)
  end
end

class TestRedirect < Minitest::Test

  def setup
    @ctx = OpenStruct.new({ root: '/de' })
  end

  def test_reusing_config_multiple_times
    config = {'exec' => "touch /foo"}
    ctx = OpenStruct.new({ root: '/build' })
    assert_equal({'exec' => "touch /build/foo"}, Config.redirect(config, ctx, Config.keys))
    ctx = OpenStruct.new({ root: '/base' })
    assert_equal({'exec' => "touch /base/foo"}, Config.redirect(config, ctx, Config.keys))
  end

  def test_redirect_with_relative_root
    config = {'exec' => "touch /foo"}
    ctx = OpenStruct.new({ root: '.' })
    assert_equal({'exec' => "touch ./foo"}, Config.redirect(config, ctx, Config.keys))
  end

  def test_redirect_with_exec_multi
    config = {'exec' => "touch //foo && echo '/foo' > /foo; tee /foo2 /foo3"}
    assert_equal({'exec' => "touch /foo && echo '/foo' > /de/foo; tee /de/foo2 /de/foo3"},
      Config.redirect(config, @ctx, Config.keys))
  end

  def test_redirect_with_exec_combo
    config = {'exec' => "touch //foo && echo '/foo' > /foo"}
    assert_equal({'exec' => "touch /foo && echo '/foo' > /de/foo"}, Config.redirect(config, @ctx, Config.keys))
  end

  def test_redirect_with_exec_host
    config = {'exec' => 'touch //foo'}
    assert_equal({'exec' => 'touch /foo'}, Config.redirect(config, @ctx, Config.keys))
  end

  def test_redirect_with_exec
    config = {'exec' => 'touch /foo'}
    assert_equal({'exec' => 'touch /de/foo'}, Config.redirect(config, @ctx, Config.keys))
  end

  def test_redirect_with_bogus
    config = {'bogus' => '/foo'}
    assert_raises(ArgumentError){Config.redirect(config, @ctx, Config.keys)}
  end

  def test_redirect_with_resolve_host
    config= {'resolve' => '//foo'}
    assert_equal({'resolve' => '/foo'}, Config.redirect(config, @ctx, Config.keys))
  end

  def test_redirect_with_resolve
    config = {'resolve' => '/foo'}
    assert_equal({'resolve' => '/de/foo'}, Config.redirect(config, @ctx, Config.keys))
  end

  def test_redirect_with_edit_host
    config = {'edit' => '//foo'}
    assert_equal({'edit' => '/foo'}, Config.redirect(config, @ctx, Config.keys))
  end

  def test_redirect_with_edit
    config = {'edit' => '/foo'}
    assert_equal({'edit' => '/de/foo'}, Config.redirect(config, @ctx, Config.keys))
  end
end

class TestMenu < Minitest::Test
  def setup
    @file = '/tmp/etc/skel/.config/openbox/menu.xml'
    @ctx = OpenStruct.new({ root: '/tmp', vars: { distro: 'foobar' } })
  end

  # Root menu tests
  #-----------------------------------------------------------------------------
  def test_add_menu_root_entry_single
    config = { 'menu' => 'Root', 'insert' => 'append', 'entry' => 'Beta', 'icon' => 'beta.png', 'exec' => 'beta' }
    mock = Minitest::Mock.new
    mock.expect(:puts, nil){|x| x.any?{|y| y.include?("Beta")} }

    Config.stub(:puts, nil){
      File.stub(:exist?, false, @file){
        File.stub(:open, true, mock){
          assert(Config.apply(config, @ctx))
        }
      }
    }

    assert_mock(mock)
  end

  def test_add_menu_root_entry_multiple_sort
    data = ["<?xml version=\"1.0\" encoding=\"utf-8\"?>", "<openbox_menu xmlns=\"http://openbox.org/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://openbox.org/\">", "  <menu id=\"root-menu\" label=\"Applications\">", "    <separator label=\"--= FOOBAR =--\"/>", "    <item label=\"Beta\" icon=\"beta.png\"><action name=\"Execute\"><execute>beta</execute></action></item>", "    <separator/>", "    <separator/>", "  </menu>", "</openbox_menu>"]

    config = { 'menu' => 'Root', 'entry' => 'Alpha', 'icon' => 'alpha.png', 'exec' => 'alpha' }

    mock = Minitest::Mock.new
    mock.expect(:puts, nil){|x|
      entries = x.select{|y| y.include?("item")}
      assert(entries.size == 2)
      assert(entries.first.include?("Alpha"))
      assert(entries.last.include?("Beta"))
    }

    Config.stub(:puts, nil){
      File.stub(:exist?, true, @file){
        File.stub(:readlines, data){
          File.stub(:open, true, mock){
            assert(Config.add_menu_entry(config, @ctx, Config.keys))
          }
        }
      }
    }

    assert_mock(mock)
  end

  def test_add_menu_root_entry_multiple_append
    data = ["<?xml version=\"1.0\" encoding=\"utf-8\"?>", "<openbox_menu xmlns=\"http://openbox.org/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://openbox.org/\">", "  <menu id=\"root-menu\" label=\"Applications\">", "    <separator label=\"--= FOOBAR =--\"/>", "    <item label=\"Beta\" icon=\"beta.png\"><action name=\"Execute\"><execute>beta</execute></action></item>", "    <separator/>", "    <separator/>", "  </menu>", "</openbox_menu>"]

    config = { 'menu' => 'Root', 'insert' => 'append', 'entry' => 'Alpha', 'icon' => 'alpha.png', 'exec' => 'alpha' }

    mock = Minitest::Mock.new
    mock.expect(:puts, nil){|x|
      entries = x.select{|y| y.include?("item")}
      assert(entries.size == 2)
      assert(entries.first.include?("Beta"))
      assert(entries.last.include?("Alpha"))
    }

    Config.stub(:puts, nil){
      File.stub(:exist?, true, @file){
        File.stub(:readlines, data){
          File.stub(:open, true, mock){
            assert(Config.add_menu_entry(config, @ctx, Config.keys))
          }
        }
      }
    }

    assert_mock(mock)
  end

  # Session menu tests
  #-----------------------------------------------------------------------------
  def test_add_menu_session_entry_single
    config = { 'menu' => 'Session', 'insert' => 'append', 'entry' => 'Beta', 'icon' => 'beta.png', 'exec' => 'beta' }
    mock = Minitest::Mock.new
    mock.expect(:puts, nil){|x| x.any?{|y| y.include?("Beta")} }

    Config.stub(:puts, nil){
      File.stub(:exist?, false, @file){
        File.stub(:open, true, mock){
          assert(Config.apply(config, @ctx))
        }
      }
    }

    assert_mock(mock)
  end

  def test_add_menu_session_entry_multiple_sort
    data = ["<?xml version=\"1.0\" encoding=\"utf-8\"?>", "<openbox_menu xmlns=\"http://openbox.org/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://openbox.org/\">", "  <menu id=\"root-menu\" label=\"Applications\">", "    <separator label=\"--= FOOBAR =--\"/>", "    <separator/>", "    <separator/>", "    <item label=\"Beta\" icon=\"beta.png\"><action name=\"Execute\"><execute>beta</execute></action></item>", "  </menu>", "</openbox_menu>"]

    config = { 'menu' => 'Session', 'entry' => 'Alpha', 'icon' => 'alpha.png', 'exec' => 'alpha' }

    mock = Minitest::Mock.new
    mock.expect(:puts, nil){|x|
      entries = x.select{|y| y.include?("item")}
      assert(entries.size == 2)
      assert(entries.first.include?("Alpha"))
      assert(entries.last.include?("Beta"))
    }

    Config.stub(:puts, nil){
      File.stub(:exist?, true, @file){
        File.stub(:readlines, data){
          File.stub(:open, true, mock){
            assert(Config.add_menu_entry(config, @ctx, Config.keys))
          }
        }
      }
    }

    assert_mock(mock)
  end

  def test_add_menu_session_entry_multiple_append
    data = ["<?xml version=\"1.0\" encoding=\"utf-8\"?>", "<openbox_menu xmlns=\"http://openbox.org/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://openbox.org/\">", "  <menu id=\"root-menu\" label=\"Applications\">", "    <separator label=\"--= FOOBAR =--\"/>", "    <separator/>", "    <separator/>", "    <item label=\"Beta\" icon=\"beta.png\"><action name=\"Execute\"><execute>beta</execute></action></item>", "  </menu>", "</openbox_menu>"]

    config = { 'menu' => 'Session', 'insert' => 'append', 'entry' => 'Alpha', 'icon' => 'alpha.png', 'exec' => 'alpha' }

    mock = Minitest::Mock.new
    mock.expect(:puts, nil){|x|
      entries = x.select{|y| y.include?("item")}
      assert(entries.size == 2)
      assert(entries.first.include?("Beta"))
      assert(entries.last.include?("Alpha"))
    }

    Config.stub(:puts, nil){
      File.stub(:exist?, true, @file){
        File.stub(:readlines, data){
          File.stub(:open, true, mock){
            assert(Config.add_menu_entry(config, @ctx, Config.keys))
          }
        }
      }
    }

    assert_mock(mock)
  end

  # Apps menu tests
  #-----------------------------------------------------------------------------
  def test_add_menu_apps_category_single
    config = { 'menu' => 'Accessories', 'icon' => 'accessories.png' }
    mock = Minitest::Mock.new
    mock.expect(:puts, nil){|x| x.any?{|y| y.include?("Accessories")} }

    Config.stub(:puts, nil){
      File.stub(:exist?, false, @file){
        File.stub(:open, true, mock){
          assert(Config.apply(config, @ctx))
        }
      }
    }

    assert_mock(mock)
  end

  def test_add_menu_apps_category_with_single_entry
    data = ["<?xml version=\"1.0\" encoding=\"utf-8\"?>", "<openbox_menu xmlns=\"http://openbox.org/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://openbox.org/\">", "  <menu id=\"root-menu\" label=\"Applications\">", "    <separator label=\"--= FOOBAR =--\"/>", "    <separator/>", "    <menu id=\"Accessories\" icon=\"accessories.png\" label=\"Accessories\">", "    </menu>", "    <separator/>", "  </menu>", "</openbox_menu>"]

    config = { 'menu' => 'Accessories', 'insert' => 'append', 'entry' => 'Beta', 'icon' => 'beta.png', 'exec' => 'beta' }

    mock = Minitest::Mock.new
    mock.expect(:puts, nil){|x|
      entries = x.select{|y| y.include?("item")}
      assert(entries.size == 1)
      assert(entries.first.include?("Beta"))
    }

    Config.stub(:puts, nil){
      File.stub(:exist?, true, @file){
        File.stub(:readlines, data){
          File.stub(:open, true, mock){
            assert(Config.apply(config, @ctx))
          }
        }
      }
    }

    assert_mock(mock)
  end

  def test_add_menu_apps_category_sub
    data = ["<?xml version=\"1.0\" encoding=\"utf-8\"?>", "<openbox_menu xmlns=\"http://openbox.org/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://openbox.org/\">", "  <menu id=\"root-menu\" label=\"Applications\">", "    <separator label=\"--= FOOBAR =--\"/>", "    <separator/>", "    <menu id=\"Settings\" icon=\"settings.png\" label=\"Settings\">", "    </menu>", "    <separator/>", "  </menu>", "</openbox_menu>"]

    config = { 'menu' => 'Settings>System', 'icon' => 'system.png' }

    mock = Minitest::Mock.new
    mock.expect(:puts, nil){|x|
      assert_equal(x.find{|y| y.include?('label="Settings"')}, '    <menu id="Settings" icon="settings.png" label="Settings">')
      assert_equal(x.find{|y| y.include?('label="System"')}, '      <menu id="System" icon="system.png" label="System">')
      assert(!x.any?{|y| y.include?("Settings>System")})
    }

    Config.stub(:puts, nil){
      File.stub(:exist?, true, @file){
        File.stub(:readlines, data){
          File.stub(:open, true, mock){
            assert(Config.apply(config, @ctx))
          }
        }
      }
    }

    assert_mock(mock)
  end

  def test_add_menu_apps_category_sub_entry
    data = ["<?xml version=\"1.0\" encoding=\"utf-8\"?>", "<openbox_menu xmlns=\"http://openbox.org/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://openbox.org/\">", "  <menu id=\"root-menu\" label=\"Applications\">", "    <separator label=\"--= FOOBAR =--\"/>", "    <separator/>", "    <menu id=\"Settings\" icon=\"settings.png\" label=\"Settings\">", "      <menu id=\"System\" icon=\"system.png\" label=\"System\">", "      </menu>", "    </menu>", "    <separator/>", "  </menu>", "</openbox_menu>"]

    config = { 'menu' => 'Settings>System', 'entry' => 'Beta', 'icon' => 'beta.png', 'exec' => 'beta' }

    mock = Minitest::Mock.new
    mock.expect(:puts, nil){|x|
      #puts(x)
      assert_equal(x.find{|y| y.include?('label="Settings"')}, '    <menu id="Settings" icon="settings.png" label="Settings">')
      assert_equal(x.find{|y| y.include?('label="System"')}, '      <menu id="System" icon="system.png" label="System">')
      assert_equal(x.find{|y| y.include?('label="Beta"')}, "         <item label=\"Beta\" icon=\"beta.png\"><action name=\"Execute\"><execute>beta</execute></action></item>")
      assert(!x.any?{|y| y.include?("Settings>System")})
    }

    Config.stub(:puts, nil){
      File.stub(:exist?, true, @file){
        File.stub(:readlines, data){
          File.stub(:open, true, mock){
            assert(Config.apply(config, @ctx))
          }
        }
      }
    }

    assert_mock(mock)
  end

  def test_add_menu_apps_category_sub_entry_parent
    data = ["<?xml version=\"1.0\" encoding=\"utf-8\"?>", "<openbox_menu xmlns=\"http://openbox.org/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://openbox.org/\">", "  <menu id=\"root-menu\" label=\"Applications\">", "    <separator label=\"--= FOOBAR =--\"/>", "    <separator/>", "    <menu id=\"Settings\" icon=\"settings.png\" label=\"Settings\">", "      <menu id=\"System\" icon=\"system.png\" label=\"System\">", "      </menu>", "    </menu>", "    <separator/>", "  </menu>", "</openbox_menu>"]

    config = { 'menu' => 'Settings', 'entry' => 'Beta', 'icon' => 'beta.png', 'exec' => 'beta' }

    mock = Minitest::Mock.new
    mock.expect(:puts, nil){|x|
      #puts(x)
      assert_equal(x.find{|y| y.include?('label="Settings"')}, '    <menu id="Settings" icon="settings.png" label="Settings">')
      assert_equal(x.find{|y| y.include?('label="System"')}, '      <menu id="System" icon="system.png" label="System">')
      assert_equal(x.find{|y| y.include?('label="Beta"')}, "      <item label=\"Beta\" icon=\"beta.png\"><action name=\"Execute\"><execute>beta</execute></action></item>")
      assert(!x.any?{|y| y.include?("Settings>System")})
    }

    Config.stub(:puts, nil){
      File.stub(:exist?, true, @file){
        File.stub(:readlines, data){
          File.stub(:open, true, mock){
            assert(Config.apply(config, @ctx))
          }
        }
      }
    }

    assert_mock(mock)
  end

  def test_add_menu_apps_subs_root_entry
    data = ["<?xml version=\"1.0\" encoding=\"utf-8\"?>", "<openbox_menu xmlns=\"http://openbox.org/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://openbox.org/\">", "  <menu id=\"root-menu\" label=\"Applications\">", "    <separator label=\"--= FOOBAR =--\"/>", "    <separator/>", "    <menu id=\"Settings\" icon=\"settings.png\" label=\"Settings\">", "      <menu id=\"System\" icon=\"system.png\" label=\"System\">", "      </menu>", "    </menu>", "    <separator/>", "  </menu>", "</openbox_menu>"]

    config = { 'menu' => 'Root', 'entry' => 'Beta', 'icon' => 'beta.png', 'exec' => 'beta' }

    mock = Minitest::Mock.new
    mock.expect(:puts, nil){|x|
      assert_equal(x.find{|y| y.include?('label="Settings"')}, '    <menu id="Settings" icon="settings.png" label="Settings">')
      assert_equal(x.find{|y| y.include?('label="System"')}, '      <menu id="System" icon="system.png" label="System">')
      assert_equal(x.find{|y| y.include?('label="Beta"')}, "    <item label=\"Beta\" icon=\"beta.png\"><action name=\"Execute\"><execute>beta</execute></action></item>")
      assert(!x.any?{|y| y.include?("Settings>System")})
    }

    Config.stub(:puts, nil){
      File.stub(:exist?, true, @file){
        File.stub(:readlines, data){
          File.stub(:open, true, mock){
            assert(Config.apply(config, @ctx))
          }
        }
      }
    }

    assert_mock(mock)
  end

  def test_lite_menu
    configs = [
      {"menu"=>"Root", "insert"=>"append", "entry"=>"Thunar", "icon"=>"/usr/share/icons/Paper/32x32/apps/Thunar.png", "exec"=>"thunar"},
      {"menu"=>"Root", "insert"=>"append", "entry"=>"LXTerminal", "icon"=>"/usr/share/icons/Paper/32x32/apps/lxterminal.png", "exec"=>"lxterminal"},
      {"menu"=>"Root", "insert"=>"append", "entry"=>"Screenshot", "icon"=>"/usr/share/icons/Paper/32x32/apps/gnome-screenshot.png", "exec"=>"xfce4-screenshooter"},
      {"menu"=>"Root", "insert"=>"append", "entry"=>"Nitrogen", "icon"=>"/usr/share/icons/hicolor/32x32/apps/nitrogen.png", "exec"=>"nitrogen"},
      {"menu"=>"Accessories", "icon"=>"/usr/share/icons/Paper/32x32/categories/applications-utilities.png"},
      {"menu"=>"Development", "icon"=>"/usr/share/icons/Paper/32x32/categories/applications-development.png"},
      {"menu"=>"Graphics", "icon"=>"/usr/share/icons/Paper/32x32/categories/applications-graphics.png"},
      {"menu"=>"Multimedia", "icon"=>"/usr/share/icons/Paper/32x32/categories/applications-multimedia.png"},
      {"menu"=>"Network", "icon"=>"/usr/share/icons/Paper/32x32/categories/applications-internet.png"},
      {"menu"=>"Office", "icon"=>"/usr/share/icons/Paper/32x32/categories/applications-office.png"},
      {"menu"=>"Settings", "icon"=>"/usr/share/icons/Paper/32x32/categories/applications-accessories.png"},
      {"menu"=>"Settings>Desktop/Login", "icon"=>"/usr/share/icons/Paper/32x32/apps/preferences-system-login.png"},
      {"menu"=>"Settings>Pacman/Servers", "icon"=>"/usr/share/icons/Paper/32x32/apps/software-center.png"},
      {"menu"=>"System", "icon"=>"/usr/share/icons/Paper/32x32/categories/applications-system.png"},
      {"menu"=>"Session", "insert"=>"append", "entry"=>"Run...", "icon"=>"/usr/share/icons/Paper/32x32/mimetypes/application-x-executable.png", "exec"=>"dmenu_run -fn -misc-fixed-*-*-*-*-20-200-*-*-*-*-*-*  -i -nb '#000000' -nf '#efefef' -sf '#000000' -sb '#3cb0fd'"},
      {"menu"=>"Session", "insert"=>"append", "entry"=>"Logout", "icon"=>"/usr/share/icons/Paper/32x32/actions/exit.png", "exec"=>"openbox --exit"},
      {"menu"=>"Session", "insert"=>"append", "entry"=>"Reboot", "icon"=>"/usr/share/icons/hicolor/32x32/actions/system-reboot.png", "exec"=>"sudo reboot"},
      {"menu"=>"Session", "insert"=>"append", "entry"=>"Shutdown", "icon"=>"/usr/share/icons/hicolor/32x32/actions/system-shutdown.png", "exec"=>"sudo poweroff"},
      {"menu"=>"Graphics", "entry"=>"Nitrogen", "icon"=>"/usr/share/icons/hicolor/32x32/apps/nitrogen.png", "exec"=>"nitrogen"},
      {"menu"=>"Accessories", "entry"=>"Archive Manager", "icon"=>"/usr/share/icons/Paper/32x32/apps/file-roller.png", "exec"=>"file-roller"},
      {"menu"=>"Accessories", "entry"=>"Bulk Rename", "icon"=>"/usr/share/icons/Paper/32x32/apps/Thunar.png", "exec"=>"/usr/lib/Thunar/ThunarBulkRename"},
      {"menu"=>"Settings", "entry"=>"Thunar Settings", "icon"=>"/usr/share/icons/Paper/32x32/apps/system-file-manager.png", "exec"=>"thunar-settings"},
      {"menu"=>"Settings", "entry"=>"Thunar Volman", "icon"=>"/usr/share/icons/Paper/32x32/devices/drive-removable-media.png", "exec"=>"thunar-volman-settings"},
      {"menu"=>"Settings>Desktop/Login", "entry"=>"LXDM Config", "icon"=>"/usr/share/icons/Paper/32x32/apps/gvim.png", "exec"=>"sudo gvim /etc/lxdm/lxdm.conf"},
      {"menu"=>"Settings>Desktop/Login", "entry"=>"Tint2 Panel", "icon"=>"/usr/share/icons/Paper/32x32/apps/gvim.png", "exec"=>"gvim ~/.config/tint2/tint2rc"},
      {"menu"=>"Settings>Pacman/Servers", "entry"=>"Pacman Config", "icon"=>"/usr/share/icons/Paper/32x32/apps/gvim.png", "exec"=>"sudo gvim /etc/pacman.conf"},
      {"menu"=>"Settings>Pacman/Servers", "entry"=>"Pacman Mirrorlist", "icon"=>"/usr/share/icons/Paper/32x32/apps/gvim.png", "exec"=>"sudo gvim /etc/pacman.d/mirrorlist"},
      {"menu"=>"Settings", "entry"=>"Dconf Editor", "icon"=>"/usr/share/icons/Paper/32x32/apps/dconf-editor.png", "exec"=>"dconf-editor"},
      {"menu"=>"Settings", "entry"=>"Gconf Editor", "icon"=>"/usr/share/icons/Paper/32x32/apps/gconf-editor.png", "exec"=>"gconf-editor"},
      {"menu"=>"Settings", "entry"=>"LXAppearance", "icon"=>"/usr/share/icons/Paper/32x32/apps/preferences-desktop-theme.png", "exec"=>"lxappearance"},
      {"menu"=>"Settings", "entry"=>"LXInput", "icon"=>"/usr/share/icons/Paper/32x32/apps/preferences-desktop-keyboard.png", "exec"=>"lxinput"},
      {"menu"=>"Settings", "entry"=>"LXRandR", "icon"=>"/usr/share/icons/Paper/32x32/apps/preferences-desktop-display.png", "exec"=>"lxrandr"},
      {"menu"=>"Settings", "entry"=>"Tint2 Themes", "icon"=>"/usr/share/icons/Paper/32x32/apps/tint2conf.png", "exec"=>"tint2conf"},
      {"menu"=>"Settings", "entry"=>"Reconfigure Openbox", "icon"=>"/usr/share/icons/Paper/32x32/apps/update-manager.png", "exec"=>"openbox --reconfigure"},
      {"menu"=>"Settings>Desktop/Login", "entry"=>"Openbox Autostart", "icon"=>"/usr/share/icons/Paper/32x32/apps/gvim.png", "exec"=>"gvim ~/.config/openbox/autostart"},
      {"menu"=>"Settings>Desktop/Login", "entry"=>"Openbox RC", "icon"=>"/usr/share/icons/Paper/32x32/apps/gvim.png", "exec"=>"gvim ~/.config/openbox/rc.xml"},
      {"menu"=>"Settings>Desktop/Login", "entry"=>"Openbox Menu", "icon"=>"/usr/share/icons/Paper/32x32/apps/gvim.png", "exec"=>"gvim ~/.config/openbox/menu.xml"},
      {"menu"=>"Settings>Desktop/Login", "entry"=>"Oblogout", "icon"=>"/usr/share/icons/Paper/32x32/apps/gvim.png", "exec"=>"sudo gvim /etc/oblogout.conf"},
      {"menu"=>"Accessories", "entry"=>"FileLight", "icon"=>"/usr/share/icons/hicolor/32x32/apps/filelight.png", "exec"=>"filelight"},
      {"menu"=>"Multimedia", "entry"=>"Audacious", "icon"=>"/usr/share/icons/hicolor/32x32/apps/audacious.png", "exec"=>"audacious"},
      {"menu"=>"Accessories", "entry"=>"Galculator", "icon"=>"/usr/share/icons/Paper/32x32/apps/galculator.png", "exec"=>"galculator"},
      {"menu"=>"Accessories", "entry"=>"Leafpad", "icon"=>"/usr/share/icons/hicolor/32x32/apps/leafpad.png", "exec"=>"leafpad"},
      {"menu"=>"Accessories", "entry"=>"Screenshot", "icon"=>"/usr/share/icons/Paper/32x32/apps/applets-screenshooter.png", "exec"=>"xfce4-screenshooter"},
      {"menu"=>"Development", "entry"=>"GVim", "icon"=>"/usr/share/icons/Paper/32x32/apps/gvim.png", "exec"=>"gvim -f"},
      {"menu"=>"Graphics", "entry"=>"Image Viewer", "icon"=>"/usr/share/icons/Paper/32x32/apps/gpicview.png", "exec"=>"gpicview"},
      {"menu"=>"Graphics", "entry"=>"XnViewMP", "icon"=>"/opt/xnviewmp/xnview.png", "exec"=>"xnviewmp"},
      {"menu"=>"Multimedia", "entry"=>"Pulse Audio", "icon"=>"/usr/share/icons/Paper/32x32/apps/multimedia-volume-control.png", "exec"=>"pavucontrol"},
      {"menu"=>"Multimedia", "entry"=>"SMPlayer", "icon"=>"/usr/share/icons/hicolor/32x32/apps/smplayer.png", "exec"=>"smplayer"},
      {"menu"=>"Multimedia", "entry"=>"VLC", "icon"=>"/usr/share/icons/hicolor/32x32/apps/vlc.png", "exec"=>"vlc"},
      {"menu"=>"Multimedia", "entry"=>"WinFF", "icon"=>"/usr/share/icons/hicolor/32x32/apps/winff.png", "exec"=>"winff"},
      {"menu"=>"Network", "entry"=>"Chromium", "icon"=>"/usr/share/icons/Paper/32x32/apps/chromium.png", "exec"=>"chromium"},
      {"menu"=>"Network", "entry"=>"FileZilla", "icon"=>"/usr/share/icons/Paper/32x32/apps/filezilla.png", "exec"=>"filezilla"},
      {"menu"=>"Network", "entry"=>"Zenmap", "icon"=>"/usr/share/zenmap/pixmaps/zenmap.png", "exec"=>"sudo zenmap"},
      {"menu"=>"Office", "entry"=>"Evince", "icon"=>"/usr/share/icons/Paper/32x32/apps/evince.png", "exec"=>"evince"},
      {"menu"=>"Settings", "entry"=>"Printer Preferences", "icon"=>"/usr/share/icons/Paper/32x32/devices/preferences-desktop-printer.png", "exec"=>"sudo system-config-printer"},
      {"menu"=>"System", "entry"=>"Htop", "icon"=>"/usr/share/icons/Paper/32x32/apps/htop.png", "exec"=>"lxterminal -e htop"}
    ]

    data = []
    @ctx = OpenStruct.new({ root: '/tmp', vars: { distro: 'cracken' } })

    # First entry test, save off data for later use
    mock1 = Minitest::Mock.new
    mock1.expect(:puts, nil){|x| data = x}
    Config.stub(:puts, nil){
      File.stub(:exist?, false, @file){
        File.stub(:open, true, mock1){
          Config.apply(configs.first, @ctx)
        }
      }
    }
    assert(data.any?{|x| x.include?('CRACKEN')})
    assert_mock(mock1)

    # Test the rest of the menu entries, saving off the data between tests
    configs[1..-1].each{|config|
      mock = Minitest::Mock.new
      mock.expect(:puts, nil){|x|
        data = x
        assert(x.find{|y| y.include?("label=\"#{config['entry']}\"")}) if config['entry']
        true
      }

      Config.stub(:puts, nil){
        File.stub(:exist?, true, @file){
          File.stub(:readlines, data){
            File.stub(:open, true, mock){
              assert(Config.apply(config, @ctx))
            }
          }
        }
      }

      assert_mock(mock)
    }

    # Test root menu order
    assert_equal(4, data.index{|x| x.include?('label="Thunar"')})
    assert_equal(5, data.index{|x| x.include?('label="LXTerminal"')})
    assert_equal(6, data.index{|x| x.include?('label="Screenshot"')})
    assert_equal(7, data.index{|x| x.include?('label="Nitrogen"')})

    # Test Desktop/Login order
    assert_equal(42, data.index{|x| x.include?('label="LXDM Config"')})
    assert_equal(43, data.index{|x| x.include?('label="Oblogout"')})
    assert_equal(44, data.index{|x| x.include?('label="Openbox Autostart"')})
    assert_equal(45, data.index{|x| x.include?('label="Openbox Menu"')})
    assert_equal(46, data.index{|x| x.include?('label="Openbox RC"')})
    assert_equal(47, data.index{|x| x.include?('label="Tint2 Panel"')})

    #puts(data)
  end
end

# vim: ft=ruby:ts=2:sw=2:sts=2
