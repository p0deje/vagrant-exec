module VagrantPlugins
  module Exec
    class Config < Vagrant.plugin(2, :config)

      attr_accessor :folder
      attr_accessor :bundler

      def initialize
        @folder  = UNSET_VALUE
        @bundler = UNSET_VALUE
      end

      def validate(_)
        return { 'exec' => ['folder should be a string'] } unless @folder.is_a?(String)
        return { 'exec' => ['bundler should be boolean'] } unless [true, false].include?(@bundler)

        {}
      end

      def finalize!
        @folder  = '/vagrant' if @folder  == UNSET_VALUE
        @bundler = false      if @bundler == UNSET_VALUE
      end

    end # Config
  end # Exec
end # VagrantPlugins
