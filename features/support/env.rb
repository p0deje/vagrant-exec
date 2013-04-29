require 'aruba/cucumber'

Before do
  # VM start takes a long time
  @aruba_timeout_seconds = 60
end

After do
  # halt VM
  system "cd tmp/aruba; bundle exec vagrant halt &> /dev/null"
end
