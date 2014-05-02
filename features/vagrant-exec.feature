@no-clobber
Feature: vagrant-exec
  In order to execute commands in Vagrant box
  Within context of synced folder
  As a developer using vagrant-exec plugin
  I want to use "vagrant exec" command

  Background:
    Given I write to "Vagrantfile" with:
      """
      $LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)
      require 'vagrant-exec'

      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
      end
      """

  Scenario Outline: shows help correctly
    Given I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec <args>`
    Then the output should contain "Usage: vagrant exec [options] <command>"
    Examples:
      | args          |
      |               |
      | -h            |
      | --help        |
      | -h pwd        |
      | --help pwd -h |

  Scenario Outline: passes command arguments correctly
    Given I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec <cmd>`
    Then SHH subprocess should execute command "cd /vagrant && <cmd>"
    Examples:
      | cmd                   |
      | cwd .                 |
      | cwd ~                 |
      | cwd -h                |
      | cwd --blah            |
      | "cwd -h blah -v blah" |
