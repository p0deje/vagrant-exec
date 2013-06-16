module VagrantPlugins
  module Exec
    class Config < Vagrant.plugin(2, :config)

      attr_reader :env
      attr_accessor :bundler
      attr_accessor :folder

      def initialize
        @env     = {}
        @bundler = UNSET_VALUE
        @folder  = UNSET_VALUE
      end

      def validate(_)
        return { 'exec' => ['bundler should be boolean'] } unless [true, false].include?(@bundler)
        return { 'exec' => ['folder should be a string'] } unless @folder.is_a?(String)

        {}
      end

      def finalize!
        @folder  = '/vagrant' if @folder  == UNSET_VALUE
        @bundler = false      if @bundler == UNSET_VALUE
      end

    end # Config
  end # Exec
end # VagrantPlugins
