module VagrantPlugins
  module Exec
    class Config < Vagrant.plugin(2, :config)

      attr_reader :env
      attr_accessor :bundler
      attr_accessor :root

      def initialize
        @env     = {}
        @bundler = UNSET_VALUE
        @root    = UNSET_VALUE
      end

      def validate(_)
        return { 'exec' => ['bundler should be boolean'] } unless [true, false].include?(@bundler)
        return { 'exec' => ['root should be a string'] }   unless @root.is_a?(String)

        {}
      end

      def finalize!
        @root    = '/vagrant' if @root    == UNSET_VALUE
        @bundler = false      if @bundler == UNSET_VALUE
      end

    end # Config
  end # Exec
end # VagrantPlugins
