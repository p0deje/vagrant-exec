$:.push File.expand_path("../lib", __FILE__)
require 'vagrant-exec/version'

Gem::Specification.new do |s|
  s.name        = 'vagrant-exec'
  s.version     = VagrantPlugins::Exec::VERSION
  s.platform    = Gem::Platform::RUBY
  s.author      = 'Alex Rodionov'
  s.email       = 'p0deje@gmail.com'
  s.homepage    = 'http://github.com/p0deje/vagrant-exec'
  s.summary     = 'Execute commands in Vagrant synced folder'
  s.description = 'Vagrant plugin to execute commands within the context of VM synced folder'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = %w(lib)

  s.add_development_dependency 'aruba'
end
