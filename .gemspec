spec = File.read(File.expand_path(File.dirname(__FILE__), 'spec.yml'))
cyberlinux_ver = spec[/\s*release:\s*(\d+\.\d+\.\d+)/, 1]

Gem::Specification.new do |x|
  gem.name        = 'reduce'
  gem.version     = cyberlinux_ver
  gem.platform    = Gem::Platform::RUBY
  gem.authors     = ['phR0ze']
  gem.homepage    = 'http://github.com/phR0ze/cyberlinux'
  gem.summary     = 'Build and deploy cyberlinux'
  gem.description = 'Build and deploy cyberlinux'
  gem.license     = 'MIT'
  gem.has_rdoc    = false

  gem.required_ruby_version = '>= 2.4'
  gem.add_runtime_dependency('colorize', ['>= 0.8.1'])
  gem.add_runtime_dependency('filesize', ['>= 0.1.1'])
  gem.add_runtime_dependency('net/scp', ['>= 1.2.1'])
  gem.add_runtime_dependency('net/ssh', ['>= 4.1.0'])
end

# vim: ft=ruby:ts=2:sw=2:sts=2
