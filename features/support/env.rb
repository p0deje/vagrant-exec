require 'aruba/cucumber'
require 'pry-byebug'
ENV['VAGRANT_LOG'] = 'info'

Before do
  # VM start takes a long time
  @aruba_timeout_seconds = 60
end
