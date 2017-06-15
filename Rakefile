task :default => :build

task :build do
  system("bundle install --system")
  exit(1) if not system("./test.rb -p")
end

# vim: ft=ruby:ts=2:sw=2:sts=2
