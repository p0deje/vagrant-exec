module VagrantPlugins
  module Exec
    module SSHHelper

      SSH_CONFIG = '.vagrant/ssh_config'.freeze

      private

      # @todo Pretty much copy-paste of vagrant 'plugins/commands/ssh_config'
      def save_ssh_config(host, ssh_info)
        raise Vagrant::Errors::SSHNotReady if ssh_info.nil?

        variables = {
          host_key: host || "vagrant",
          ssh_host: ssh_info[:host],
          ssh_port: ssh_info[:port],
          ssh_user: ssh_info[:username],
          private_key_path: ssh_info[:private_key_path],
          forward_agent: ssh_info[:forward_agent],
          forward_x11: ssh_info[:forward_x11],
          proxy_command: ssh_info[:proxy_command]
        }

        template = 'commands/ssh_config/config'
        config = Vagrant::Util::TemplateRenderer.render(template, variables)

        File.open(SSH_CONFIG, 'w') { |file| file.write(config) }
      end

    end # SSHHelper
  end # Exec
end # VagrantPlugins
