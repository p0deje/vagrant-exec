module VagrantPlugins
  module Exec
    class Command < Vagrant.plugin(2, :command)

      def execute
        opts = OptionParser.new do |o|
          o.banner = 'Usage: vagrant exec [options] <command>'
          o.separator ''

          o.on('-h', '--help', 'Print this help') do
            safe_puts(opts.help)
          end
        end

        argv = split_main_and_subcommand(@argv.dup)
        exec_args, cmd, cmd_args = argv[0], argv[1], argv[2]

        # show help
        if !cmd || exec_args.any? { |a| a == '-h' || a == '--help' }
          safe_puts(opts.help)
          return nil
        end

        # Execute the actual SSH
        with_target_vms(nil, single_target: true) do |vm|
          vm.config.exec.finalize! # TODO: do we have to call it explicitly?

          plain   = "#{cmd} " << cmd_args.join(' ')
          command = "cd #{vm.config.exec.folder} && "

          env = vm.config.exec.env
          if env.any?
            env.each do |key, value|
              command << "export #{key}=#{value} && "
            end
          end

          if vm.config.exec.bundler && !(plain =~ /^bundle /)
            command << 'bundle exec '
          end

          command << plain

          @logger.info("Executing single command on remote machine: #{command}")
          env = vm.action(:ssh_run, ssh_run_command: command)

          status = env[:ssh_run_exit_status] || 0
          return status
        end
      end

    end # Command
  end # Exec
end # VagrantPlugins
