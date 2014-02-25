module VagrantPlugins
  module Exec
    class Command < Vagrant.plugin(2, :command)

      def self.synopsis
        'proxies command to VM synced folder root'
      end

      def execute
        cmd, cmd_args = parse_args
        cmd && cmd_args or return nil

        # Execute the actual SSH
        with_target_vms(nil, single_target: true) do |vm|
          vm.config.exec.finalize! # TODO: do we have to call it explicitly?

          plain = cmd.dup
          plain << ' ' << cmd_args.join(' ') unless cmd_args.empty?

          command  = "cd #{vm.config.exec.root} && "
          command << add_env(vm.config.exec.env)
          command << prepend_command(vm.config.exec.prepends, plain)
          command << plain

          @logger.info("Executing single command on remote machine: #{command}")
          ssh_opts = { extra_args: ['-q'] } # make it quiet
          env = vm.action(:ssh_run, ssh_run_command: command, ssh_opts: ssh_opts)

          status = env[:ssh_run_exit_status] || 0
          return status
        end
      end

      private

      def parse_args
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

        # remove "--" arg which is added by Vagrant
        # https://github.com/p0deje/vagrant-exec/issues/2
        cmd_args.delete_if { |a| a == '--' }

        return cmd, cmd_args
      end

      def add_env(env)
        ''.tap do |cmd|
          env.each do |key, value|
            cmd << "export #{key}=#{value} && "
          end if env.any?
        end
      end

      def prepend_command(prepends, command)
        bin = command.split(' ').first
        ''.tap do |cmd|
          prepends.each do |prep|
            if !prep[:only] || prep[:only].include?(bin)
              custom_root = prep[:root].strip
              cmd << "cd #{custom_root} && " if custom_root
              prep = prep[:command].strip # remove trailing space
              cmd << "#{prep} "
            end
          end if prepends.any?
        end
      end

    end # Command
  end # Exec
end # VagrantPlugins
