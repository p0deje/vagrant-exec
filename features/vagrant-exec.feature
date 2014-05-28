@no-clobber
Feature: vagrant-exec
  In order to execute commands in Vagrant box
  Within context of synced folder
  As a developer using vagrant-exec plugin
  I want to use "vagrant exec" command

  Background:
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
      end
      """
    And I run `bundle exec vagrant up`

  Scenario Outline: shows help correctly
    When I run `bundle exec vagrant exec <args>`
    Then the output should contain:
      """
      Usage: vagrant exec [options] <command>

          -h, --help                       Print this help
              --binstubs                   Generate binstubs for configured commands
      """
    Examples:
      | args          |
      |               |
      | -h            |
      | --help        |
      | -h pwd        |
      | --help pwd -h |

  Scenario Outline: passes command arguments correctly
    When I run `bundle exec vagrant exec <command>`
    Then SHH subprocess should execute command "cd /vagrant && <command>"
    Examples:
      | command               |
      | pwd .                 |
      | pwd ~                 |
      | pwd -h                |
      | pwd --blah            |
      | 'pwd -h blah -v blah' |
