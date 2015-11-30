module VagrantPlugins
  module Exec
    class CommandConstructor

      def initialize(command, config, guest)
        @command = command.dup
        @config = config
        @guest = guest
      end

      def construct_command
        ''.tap do |constructed_command|
          # directory is applied only once in the beginning
          @config.reverse.each do |command|
            if command_matches?(command[:cmd], @command) && !directory_added?
              if command[:opts][:directory]
                constructed_command << add_directory(command[:opts][:directory])
              else
                if @guest == :windows
                  constructed_command << add_directory('C:\vagrant')
                else
                  constructed_command << add_directory('/vagrant')
                end
              end
            end
          end

          # apply environment variables
          @config.each do |command|
            if command_matches?(command[:cmd], @command)
              constructed_command << add_env(command[:opts][:env])
            end
          end

          # apply prepend in the end
          @config.each do |command|
            if command_matches?(command[:cmd], @command)
              constructed_command << add_prepend(command[:opts][:prepend])
            end
          end

          constructed_command << @command
        end
      end

      private

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
            if @guest == :windows
              str << "set #{key}=#{value} && "
            else
              str << "export #{key}=#{value} && "
            end
          end if env
        end
      end

      def add_prepend(prep)
        ''.tap do |str|
          str << "#{prep.strip} " if prep
        end
      end

      def command_matches?(expected, actual)
        expected == '*' || expected == actual || expected.include?(actual)
      end


      def directory_added?
        !!@directory_added
      end

    end # CommandConstructor
  end # Exec
end # VagrantPlugins
