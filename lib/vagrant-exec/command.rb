module VagrantPlugins
  module Exec
    class Command < Vagrant.plugin(2, :command)

      def self.synopsis
        'executes commands in virtual machine'
      end

      def execute
        cmd, cmd_args = parse_args
        cmd && cmd_args or return nil

        # Execute the actual SSH
        with_target_vms(nil, single_target: true) do |vm|
          settings = vm.config.exec._parsed_commands
          passed_command, constructed_command = cmd.dup, ''

          # directory is applied only once in the beginning
          settings.reverse.each do |command|
            if command_matches?(command[:cmd], passed_command) && !directory_added?
              constructed_command << add_directory(command[:opts][:directory])
            end
          end

          # apply environment variables
          settings.each do |command|
            if command_matches?(command[:cmd], passed_command)
              constructed_command << add_env(command[:opts][:env])
            end
          end

          # apply prepend in the end
          settings.each do |command|
            if command_matches?(command[:cmd], passed_command)
              constructed_command << add_prepend(command[:opts][:prepend])
            end
          end

          constructed_command << passed_command
          constructed_command << ' ' << cmd_args.join(' ') if cmd_args.any?

          @logger.info("Executing single command on remote machine: #{constructed_command}")
          ssh_opts = { extra_args: ['-q'] } # make it quiet
          env = vm.action(:ssh_run, ssh_run_command: constructed_command, ssh_opts: ssh_opts)

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

      def add_directory(directory)
        ''.tap do |str|
          if directory
            str << "cd #{directory} && "
            @directory_added = true
          end
        end
      end

      def add_env(env)
        ''.tap do |str|
          env.each do |key, value|
            value = %("#{value}") if value.is_a?(String) && value.include?(' ')
            str << "export #{key}=#{value} && "
          end if env
        end
      end

      def add_prepend(prep)
        ''.tap do |str|
          str << "#{prep.strip} " if prep
        end
      end

      def command_matches?(expected, actual)
        expected =='*' || expected == actual || expected.include?(actual)
      end

      def directory_added?
        !!@directory_added
      end

    end # Command
  end # Exec
end # VagrantPlugins
