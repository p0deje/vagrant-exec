module VagrantPlugins
  module Exec
    class Config < Vagrant.plugin(2, :config)

      attr_reader :env
      attr_accessor :root

      def initialize
        @env          = {}
        @prepend_with = UNSET_VALUE
        @root         = UNSET_VALUE
      end

      def prepend_with(command, opts = {})
        @prepend_with = [] if @prepend_with == UNSET_VALUE
        @prepend_with << { :command => command }.merge(opts)
      end

      def prepends
        @prepend_with
      end

      def validate(_)
        return { 'exec' => ['root should be a string'] } unless @root.is_a?(String)
        if @prepend_with.any?
          if !@prepend_with.all? { |p| p[:command].is_a?(String) }
            return { 'exec' => ['prepend_with command should be a string'] }
          end
          if !@prepend_with.all? { |p| !p[:only] || p[:only].is_a?(Array) }
            return { 'exec' => ['prepend_with :only should be an array'] }
          end
          if !@prepend_with.all? { |p| !p[:root] || p[:root].is_a?(String) }
            return { 'exec' => ['prepend_with :root should be a string'] }
          end
        end

        {}
      end

      def finalize!
        @root = '/vagrant' if @root == UNSET_VALUE
        @prepend_with = [] if @prepend_with == UNSET_VALUE
      end

    end # Config
  end # Exec
end # VagrantPlugins
