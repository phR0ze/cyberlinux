Gem::Specification.new do |spec|
  spec.name        = 'reduce'
  spec.summary     = "Build tool for cyberlinux"
  spec.authors     = ["Patrick Crummett"]
  spec.homepage    = 'https://github.com/phR0ze/cyberlinux'
  spec.license     = 'MIT'

  # Runtime dependencies
  spec.add_dependency('colorize', '>= 0.8.1')
  spec.add_dependency('filesize', '>= 0.1.1')
  spec.add_dependency('minitest', '>= 5.11.3')
  spec.add_dependency('net-scp', '>= 1.2.1')
  spec.add_dependency('net-ssh', '>= 4.2.0')
  spec.add_dependency('rake')

  # Development dependencies
  spec.add_development_dependency('bundler')
  spec.add_development_dependency('rake')
end
# vim: ft=ruby:ts=2:sw=2:sts=2
