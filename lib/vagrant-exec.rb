require 'vagrant'

require 'vagrant-exec/plugin'
require 'vagrant-exec/version'


# HACK: make vagrant-exec compatible with vagrant 1.6
# remove when https://github.com/mitchellh/vagrant/pull/3670 is merged
class Vagrant::Config::V2::Root
  def exec
    method_missing(:exec)
  end
end

