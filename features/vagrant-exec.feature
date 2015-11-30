@no-clobber
Feature: vagrant-exec
  In order to execute commands in Vagrant box
  Within context of synced folder
  As a developer using vagrant-exec plugin
  I want to use "vagrant exec" command

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

  @posix
  Scenario Outline: passes command arguments correctly
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure('2') do |config|
        config.vm.box = 'hashicorp/precise64'
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec <command>`
    Then SHH subprocess should execute command "cd /vagrant && <command>"
    Examples:
      | command               |
      | pwd .                 |
      | pwd ~                 |
      | pwd -h                |
      | pwd --blah            |
      | 'pwd -h blah -v blah' |

  @windows
  Scenario Outline: passes command arguments correctly
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure('2') do |config|
        config.vm.box = 'ferventcoder/win7pro-x64-nocm-lite'
        config.vm.guest = :windows
        config.vm.network :forwarded_port, guest: 22, host: 2222, id: 'ssh'
        config.vm.communicator = :winrm
        config.winrm.username = 'vagrant'
        config.winrm.password = 'vagrant'
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec <command>`
    Then SHH subprocess should execute command "cd C:\windows && <command>"
    Examples:
      | command               |
      | dir .                 |
      | dir -h                |
      | dir --blah            |
      | 'dir -h blah -v blah' |
