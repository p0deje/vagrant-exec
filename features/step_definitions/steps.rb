Given(/^I have default Vagrantfile$/) do
  vagrantfile = <<-RUBY
Vagrant.require_plugin 'vagrant-exec'

Vagrant.configure('2') do |config|
  config.vm.box = 'precise32'
end
  RUBY
  step 'a file named "Vagrantfile" with:', vagrantfile
end

Given(/^I set vagrant-exec folder to (.+)$/) do |folder|
  config = <<-RUBY

Vagrant.configure('2') do |config|
  config.exec.folder = #{folder}
end
  RUBY
  step 'I append to "Vagrantfile" with:', config
end

Given(/^I set vagrant-exec bundler to (.+)$/) do |bundler|
  config = <<-RUBY

Vagrant.configure('2') do |config|
  config.exec.bundler = #{bundler}
end
  RUBY
  step 'I append to "Vagrantfile" with:', config
end
