unless `bundle exec vagrant box list`.include?('vagrant_exec')
  raise 'Box is not added! Run "rake features:bootstrap".'
end

require 'aruba/cucumber'
require 'pry-byebug'
ENV['VAGRANT_LOG'] = 'info'

Before do
  # VM start takes a long time
  @aruba_timeout_seconds = 60
end

After do
  # halt VM
  system 'cd tmp/aruba; bundle exec vagrant halt &> /dev/null'
end
