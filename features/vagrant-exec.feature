@no-clobber
Feature: vagrant-exec
  In order to execute commands in Vagrant box
  Within context of root synced folder
  As a developer using vagrant-exec plugin
  I want to use "vagrant exec" command
  And be able to customize folder
  And prepend commands with "bundle exec"
  And set exported environmental variables
  Using Vagrantfile configuration

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

  Scenario: uses /vagrant as default root
    Given I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec pwd`
    Then the exit status should be 0
    And SHH subprocess should execute command "cd /vagrant && pwd"

  Scenario: can use custom root
    Given I overwrite "Vagrantfile" with:
      """
      $LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)
      require 'vagrant-exec'

      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
        config.exec.root = '/tmp'
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec pwd`
    Then the exit status should be 0
    And SHH subprocess should execute command "cd /tmp && pwd"

  Scenario: raises error if root is improperly set
    Given I overwrite "Vagrantfile" with:
      """
      $LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)
      require 'vagrant-exec'

      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
        config.exec.root = true
      end
      """
    And I run `bundle exec vagrant up`
    Then the exit status should not be 0
    And the output should contain "root should be a string"

  Scenario: can prepend all commands
    Given I overwrite "Vagrantfile" with:
      """
      $LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)
      require 'vagrant-exec'

      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
        config.exec.prepend_with 'echo vagrant-exec &&'
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec pwd`
    Then the exit status should be 0
    And SHH subprocess should execute command "cd /vagrant && echo vagrant-exec && pwd"

  Scenario: can prepend only specific commands
    Given I overwrite "Vagrantfile" with:
      """
      $LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)
      require 'vagrant-exec'

      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
        config.exec.prepend_with 'echo vagrant-exec &&', :only => %w(pwd echo)
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec pwd`
    Then SHH subprocess should execute command "cd /vagrant && echo vagrant-exec && pwd"
    When I run `bundle exec vagrant exec echo 1`
    Then SHH subprocess should execute command "cd /vagrant && echo vagrant-exec && echo 1"
    When I run `bundle exec vagrant exec env`
    Then SHH subprocess should execute command "cd /vagrant && env"

  Scenario: can use prepend multiple times
    Given I overwrite "Vagrantfile" with:
      """
      $LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)
      require 'vagrant-exec'

      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
        config.exec.prepend_with 'echo vagrant-exec1 &&', :only => %w(pwd)
        config.exec.prepend_with 'echo vagrant-exec2 &&', :only => %w(echo)
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec pwd`
    Then SHH subprocess should execute command "cd /vagrant && echo vagrant-exec1 && pwd"
    When I run `bundle exec vagrant exec echo 1`
    Then SHH subprocess should execute command "cd /vagrant && echo vagrant-exec2 && echo 1"

  Scenario: raises error if prepend command is improperly set
    Given I overwrite "Vagrantfile" with:
      """
      $LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)
      require 'vagrant-exec'

      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
        config.exec.prepend_with :test
      end
      """
    Given I set vagrant-exec prepend with :test for all commands
    And I run `bundle exec vagrant up`
    Then the exit status should not be 0
    And the output should contain "prepend_with command should be a string"

  Scenario: raises error if prepend only is improperly set
    Given I overwrite "Vagrantfile" with:
      """
      $LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)
      require 'vagrant-exec'

      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
        config.exec.prepend_with 'echo vagrant-exec1 &&', :only => 'test'
      end
      """
    And I run `bundle exec vagrant up`
    Then the exit status should not be 0
    And the output should contain "prepend_with :only should be an array"

  Scenario: can export environment variables
    Given I overwrite "Vagrantfile" with:
      """
      $LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)
      require 'vagrant-exec'

      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
        config.exec.env['TEST1'] = true
        config.exec.env['TEST2'] = false
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec pwd`
    Then the exit status should be 0
    And SHH subprocess should execute command "cd /vagrant && export TEST1=true && export TEST2=false && pwd"
