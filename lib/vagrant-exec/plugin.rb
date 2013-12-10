module VagrantPlugins
  module Exec
    class Plugin < Vagrant.plugin(2)

      name 'vagrant-exec'
      description 'Plugin allows to execute commands within the context of synced folder.'

      config :exec do
        require_relative 'config'
        Config
      end

      command :exec do
        require_relative 'command'
        Command
      end

    end # Plugin
  end # Exec
end # VagrantPlugins
