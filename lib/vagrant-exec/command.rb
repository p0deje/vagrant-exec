module VagrantPlugins
  module Exec
    class Command < Vagrant.plugin(2, :command)

      include SSHHelper

      def self.synopsis
        'executes commands in virtual machine'
      end

      def execute
        cmd, cmd_args = parse_args
        cmd && cmd_args or return nil

        # Execute the actual SSH
        with_target_vms(nil, single_target: true) do |vm|
          constructor = CommandConstructor.new(cmd, vm.config.exec.commands)
          command = constructor.construct_command
          command << ' ' << cmd_args.join(' ') if cmd_args.any?

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

          o.on('--binstubs', 'Generate binstubs for configured commands')
        end

        argv = split_main_and_subcommand(@argv.dup)
        exec_args, cmd, cmd_args = argv[0], argv[1], argv[2]

        # generate binstubs
        if exec_args.include?('--binstubs')
          generate_binstubs
          return nil
        end

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

      def generate_binstubs
        with_target_vms(nil, single_target: true) do |vm|
          save_ssh_config(vm.name, vm.ssh_info)

          commands = vm.config.exec.commands

          explicit = commands.select { |command| command[:cmd] != '*' }
                             .map { |command| command[:cmd] }
                             .flatten
                             .uniq

          if explicit.empty?
            vm.env.ui.error('No commands to generate binstubs for.')
            return nil
          end

          explicit = explicit.map do |command|
            {
              command: command,
              constructed: CommandConstructor.new(command, commands).construct_command
            }
          end

          shell = vm.config.ssh.shell

          Dir.mkdir('bin') unless Dir.exist?('bin')
          explicit.each do |command|
            command[:constructed].gsub!('"', '\"') # escape double-quotes

            variables = {
              ssh_config: SSH_CONFIG,
              shell: shell,
              command: command[:constructed],
            }
            variables.merge!(template_root: "#{File.dirname(__FILE__)}/templates")

            binstub = Vagrant::Util::TemplateRenderer.render('binstub', variables)

            filename = "bin/#{command[:command]}"
            File.open(filename, 'w') { |file| file.write binstub }
            File.chmod(0755, filename)

            vm.env.ui.success("Generated binstub for #{command[:command]} in #{filename}.")
          end
        end
      end

    end # Command
  end # Exec
end # VagrantPlugins
