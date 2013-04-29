module VagrantPlugins
  module Exec
    class Command < Vagrant.plugin(2, :command)

      def execute
        options = {}

        opts = OptionParser.new do | o |
          o.banner = 'Usage: vagrant exec [options] <command>'
          o.separator ''

          o.on('-m', '--machine VM', 'VM name to use.') do | vm |
            options[:machine] = vm
          end
        end

        # Parse the options
        argv = parse_options(opts)
        return unless argv

        # Execute the actual SSH
        with_target_vms(options[:machine], single_target: true) do | vm |
          vm.config.exec.finalize! # TODO: do we have to call it explicitly?

          plain = argv.join(' ')
          command =  "cd #{vm.config.exec.folder}; "
          if vm.config.exec.bundler && !(plain =~ /^bundle /)
            command << 'bundle exec '
          end
          command << plain
          @logger.debug("Executing single command on remote machine: #{command}")
          env = vm.action(:ssh_run, ssh_run_command: command)

          status = env[:ssh_run_exit_status] || 0
          return status
        end
      end

    end # Command
  end # Exec
end # VagrantPlugins
