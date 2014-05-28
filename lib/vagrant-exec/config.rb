module VagrantPlugins
  module Exec
    class Config < Vagrant.plugin(2, :config)

      DEFAULT_SETTINGS = {
        cmd: '*',
        opts: {
          directory: '/vagrant'
        }
      }.freeze

      def initialize
        @commands = UNSET_VALUE
      end

      #
      # Retrieve or add command.
      #
      # @overload commands
      #   Returns array of commands and all their options
      #
      # @overload commands(command, options)
      #   Configures command with options.
      #   @param command [String, Array<String>]
      #   @param opts [Hash]
      #   @option opts [String] :directory Directory to execute commands in
      #   @option opts [String] :prepend Command to prepend with
      #   @option opts [Hash] :env Environmental variables to export
      #
      def commands(*args)
        @commands = [] if @commands == UNSET_VALUE

        if args.empty?
          @commands
        else
          @commands << { cmd: args[0], opts: args[1] || {} }
        end
      end

      def validate(_)
        finalize!
        errors = _detected_errors

        @commands.each do |command|
          cmd, opts = command[:cmd], command[:opts]

          if !cmd.is_a?(String) && !array_of_strings?(cmd)
            errors << "Commands should be String or Array<String>, received: #{cmd.inspect}"
          end

          if opts.has_key?(:directory) && !opts[:directory].is_a?(String)
            errors << ":directory should be String, received: #{opts[:directory].inspect}"
          end

          if opts.has_key?(:prepend) && !opts[:prepend].is_a?(String)
            errors << ":prepend should be String, received: #{opts[:prepend].inspect}"
          end

          if opts.has_key?(:env) && !opts[:env].is_a?(Hash)
            errors << ":env should be Hash, received: #{opts[:env].inspect}"
          end
        end

        { 'exec' => errors }
      end

      def finalize!
        if @commands == UNSET_VALUE
          @commands = [DEFAULT_SETTINGS.dup]
        else
          # add default settings and merge options for splat
          splats, commands = @commands.partition { |command| command[:cmd] == '*' }
          commands.unshift(DEFAULT_SETTINGS.dup)
          splats.each { |splat| commands.first[:opts].merge!(splat[:opts]) }
          @commands = commands
        end
      end

      private

      def array_of_strings?(array)
        array.is_a?(Array) && array.all? { |i| i.is_a?(String) }
      end

    end # Config
  end # Exec
end # VagrantPlugins
