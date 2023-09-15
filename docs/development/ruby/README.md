# ruby
Develop in Ruby

### Table of Contents
* [Projects](#projects)
  * [Create gemspec](#create-gemspec)
  * [Unit Tests](#unit-tests)
  * [Config Travis-CI](#config-travis-ci)
  * [Badges](#badges)
* [Standalone Exec](#standalone-exec)
  * [Ruby Packer](#ruby-packer)
  * [Traveling Ruby](#traveling-ruby)
* [vscode](#vscode)
  * [Configure vscode](#configure-vscode)
  * [Debugging with vscode](#debugging-with-vscode)
* [Gem Creation](#gem-creation)
  * [Package Layout](#package-layout)
  * [Build Gem](#build-gem)
  * [Install Gem](#install-gem)
  * [Push Gem](#push-gem)
* [Game Development](#game-development)
  * [GOSU](#gosu)
* [Debugging](#debugging)
  * [Debugging with Pry](#debugging-with-pry)
* [Web Scrapping](#web-scrapping)
  * [Mechanize](#mechanize)

## Projects <a name="projects"/></a>
Every project I've done with Ruby follows the pattern I established with ruby-nub. I'm using
TravisCI for CI/CD which is running the unit test suite for every commit which provides a
pass/fail.  Each run captures code coverage via Coveralls and publishes this data.  Additionally a
new Ruby Gem is publish every time the project is tagged.

```bash
.git                  // git repo data
.githooks             // automatic version increment for project
aur                   // Arch Linux package building
bin                   // Any scripts or binaries your project will provide
example               // Examples of how to use the project
lib                   // Core reusable componets for your project
test                  // Projects tests, run with ./test/test.rb -p
.coveralls.yml        // Code coverage integration
Gemfile               // Calls out gemspec and gem repo source
.gitignore            // Standard git ignore file
LICENSE               // Github standard license file
<project>.gemspec     // Ruby gemspec for your project
Rakefile              // Unit test automation file for CI/CD
README.md             // Standard Github readme
.travis.yml           // TravisCI integration
```

### Create gemspec <a name="create-gemspec"/></a>
The first thing to do with a new Ruby project is to create your project layout and setup your CI/CD.
I'm using ***intake*** as my project example.

```bash
# Create your project gemspec
# The intake.gemspec is where you call out your project's name, version, dependencies etc...
cp ../ruby-nub/Gemfile .

tee -a intake.gemspec <<EOL
Gem::Specification.new do |spec|
  spec.name        = 'intake'
  spec.version     = '0.0.1'
  spec.summary     = "Automation for video repository syncs and name normalization"
  spec.authors     = ["Author Name"]
  spec.homepage    = 'https://github.com/phR0ze/intake'
  spec.license     = 'MIT'
  spec.files       = `git ls-files | grep lib`.split("\n") + ['LICENSE', 'README.md']

  # Runtime dependencies
  spec.add_dependency('nub', '>= 0.0.138')

  # Development dependencies
  spec.add_development_dependency('minitest', '~> 5.11.3')
  spec.add_development_dependency('coveralls', '~> 0.8')
  spec.add_development_dependency('bundler', '~> 1.16')
  spec.add_development_dependency('rake', '~> 12.0')
end
# vim: ft=ruby:ts=2:sw=2:sts=2
EOL
```

### Unit Tests <a name="unit-tests"></a>
Unit testing should be setup and used as soon as possible. All test files should be run from the
`test.rb` main file. All test files should executable as standalones as well.

**Execute tests with:** `./test/test.rb -p`

Configure coveralls:
1. Create config file:
  ```bash
  cat >> .coveralls.yml <<EOL
  service_name: travis-ci
  EOL
  ```
2. Navigate to https://coveralls.io/repos
3. Sign in using Github
4. Click `Add Repos` button on the left
5. Find `intake` and flip to ***ON***

```bash
# Create test directory
cd ~/Projects/intake
mkdir test
cp ../ruby-nub/test/test.rb test

# Ensure the test files are executable
chmod +x test/*

# Create Rake file for CI/CD to call
cat Rakefile <<EOL
task :default => :build

# Need to test log separately as it is a singleton
task :build do
  exit(1) if not system("./test/test.rb -p")
end

# vim: ft=ruby:ts=2:sw=2:sts=2
EOL
```

### Config Travis-CI <a name="config-travis-ci"></a>
Example project https://github.com/phR0ze/ruby-nub

```bash
# Install travis
sudo gem install travis --no-user-install

# Deploy Ruby Gem on Tag
Create the file ***.travis.yml***

* Using ***cache: bundler*** builds the dependencies once and then reuses them in future builds.
* Script ***rake*** is actually the default for ***ruby*** but calling it out for clarity to run unit tests
* Deploying using the ***rubygems*** provider on tags
```

```yaml
language: ruby
sudo: false
cache: bundler
rvm:
  - 1.5.0
before_install:
  - gem update --system
script:
  - rake
deploy:
  provider: rubygems
  api_key:
    secure: <encrypted key>
  gem: nub
  on:
    tags: true
notifications:
  email: false
```

### Badges <a name="bages"></a>
Add the following badges using https://github.com/phR0ze/ruby-nub as a pattern

* Coveralls
* Travis CI
* Ruby Gem

## Standalone Exec <a name="standalone-exec"></a>

### Ruby Packer <a name="ruby-packer"></a>
* http://enclose.io/
* https://github.com/pmq20/ruby-packer

Provides an ***Ahead-of-time (AOT)*** compiler designed for Ruby. Compiling your Ruby application
into a single executable.  Rails and Native C extensions Fully Supported. Open Source, MIT Licensed.

### Traveling Ruby <a name="traveling-ruby"></a>
https://github.com/phusion/traveling-ruby

## vscode <a name="vscode"></a>
Visual Studio Code is free, light weight and works awesome for Golang. Ruby is another matter. I've
had a lot of problems getting anything to work, but I'll try again with `vscode-ruby`

* Ruby extension for automatic linting and auto-formatting via RoboCop
  * Great debugging
* For intellisense - turn off that setting for ruby extension and use solargraph extension
* Open vscode from within the project folder to solve intellisense issues
  * `code .` from project always works
  * specify gem path in config for solargraph to work

* find usage?
* autocomplete?
* goto declaration?
* refactoring(rename etc...)

1. Install the gem solargraph before the extension

### Configure vscode <a name="configure-vscode"></a>
https://marketplace.visualstudio.com/items?itemName=rebornix.Ruby

1. Launch `code`
2. Install gem support:
   ```bash
   # Install ruby doc builder
   sudo gem install --no-user-install rdoc

   # Install vscode ruby support gems
   # debase               // fast debugger for Ruby 2.x
   # ruby-debug-ide       // ide interface wrapper around debase
   # solargraph           // code completion and inline documentation
   # rubocop              // automatic linting and formatting
   # ruby-lint            // linter and static code analysis
   # reek                 // examine and report code smells
   # fasterer             // finds areas of code that could be faster
   # debride              // analyze code for dead code
   sudo gem install --no-user-install debase ruby-debug-ide solargraph rubocop ruby-lint reek fasterer debride
   ```
3. Install Extensions:
   a. Click the button on the left that looks like an extension icon  
   e. Install ***Ruby rebomix.ruby***  
   f. Install ***Ruby Solargraph*** via castwide.solargraph  
4. Configure ***Ruby*** extension to turn of language server
   ```bash
   useLanguageServer = false?
   ```
4. Configure ***.solargraph.yml***
   a. Open your project folder  
   b. Switch to the in ide terminal  
   c. Run `solargraph config .`  
   d. Disable Ruby ext intellisense
      `ruby.intellisense to false`
5. Add Debug Launch configuration
   a. Press ***Ctrl+Shift+d*** to switch to the debugger view  
   b. Click the little ***gear*** then select ***Ruby***  
   c. This creates the file `.vscode/launch.json`  
   d. Install binstubs:  
      ```bash
      bundle install --binstubs
      ```
   c. Edit the files and delete everything but the ***Debug Local File*** entry  
   d. Change the ***program*** from ***main.rb*** to ***test.rb***  
6. Enable linters
   a. By default no linters are enabled  
7. Enable code formatting on save
   a. ...  

### Debugging with vscode <a name="debugging-with-vscode"></a>
https://dev.to/dnamsons/ruby-debugging-in-vscode-3bkj

```json
{
  // Use IntelliSense to learn about possible attributes.
  // Hover to view descriptions of existing attributes.
  // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Listen for rdebug-ide",
      "type": "Ruby",
      "request": "attach",
      "cwd": "${file}",
      "remoteHost": "127.0.0.1",
      "remotePort": "1234",
      "remoteWorkspaceRoot": "${file}"
    }
  ]
}
```

## Gem Creation <a name="gem-creation"></a>
http://guides.rubygems.org/make-your-own-gem/

This is my first ruby gem and am documenting what I did here

### Package Layout <a name="package-layout"></a>
All the ruby code will be in the sub directory ***lib***

* ***lib*** is where your gem's actual code should reside
* ***nub.gemspec*** is your interface to RubyGems.org all the data provided here is used by the gem
repo

### Build Gem <a name="build-gem"></a>
```
gem build nub.gemspec
```

### Install Gem <a name="install-gem"></a>
```
gem install nub-0.0.1.gem
```

### Push Gem <a name="push-gem"></a>
Once you've built and tested your gem and are happy with it push it to RubyGems.org

```bash
# Download your user credentials
curl -u phR0ze https://rubygems.org/api/v1/api_key.yaml > ~/.gem/credentials
# Enter host password for user 'phR0ze':
# Revoke read permission from everyone but you
chmod og-r ~/.gem/credentials
# Push gem
gem push nub-0.0.1.gem
# List out your gems takes about a min
gem list -r nub
```

## Game Development <a name="game-development"/></a>

### GOSU <a name="gosu"/></a>
* https://www.libgosu.org/ruby.html
* https://github.com/gosu/gosu/wiki/ruby-tutorial
* https://www.libgosu.org/cgi-bin/mwf/topic_show.pl?tid=1372

Gosu is a 2D game development library for Ruby and C++. It's available for macOS, Windows, Linux
(includeing Raspbian) and iOS. Gosu is focused, lightweight and has few dependencies (mostly SDL 2).

It provides:
* a window and main loop
* 2D graphics and text, powered by OpenGL or OpenGL ES
* sounds and music
* keyboard, mouse and gampad input
* single window only limitation
* https://github.com/psadda/gglib/tree/master/lib/gglib

## Debugging <a name="debugging"/></a>

### Debugging with Pry <a name="debugging-with-pry"/></a>
https://github.com/deivid-rodriguez/pry-byebug

```bash
# Install pry
$ sudo pacman -S ruby-pry-byebug

# Configure pry
$ vim ~/.pryrc

# Add shotcut keys
if defined?(PryByebug)
  Pry.commands.alias_command 'c', 'continue'
  Pry.commands.alias_command 's', 'step'
  Pry.commands.alias_command 'n', 'next'
  Pry.commands.alias_command 'f', 'finish'
end

# Hit Enter to repeat last command
Pry::Commands.command /^$/, "repeat last command" do
  _pry_.run_command Pry.history.to_a.last
end
```

#### Usage
#### Commands
* exit	Exit the debugger and continue running to the end
* s 		Step execution into the next line or method
* n 		Step over the next line within the same frame

#### Trigger Break
To include debugging and trigger a break, require pry in your source then call binding.pry where you'd like to break.
Example
require 'pry'
binding.pry

## Web Scraping <a name="web-scraping"/></a>

### Mechanize <a name="mechanize"/></a>

Examples:
* http://github.com/phR0ze/pacsmack
* http://github.com/phR0ze/cyberlinux/aur/chromium/chroma.rb
