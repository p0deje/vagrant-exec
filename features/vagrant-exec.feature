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

  Scenario: uses /vagrant as default directory
    Given I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec pwd`
    Then the exit status should be 0
    And SHH subprocess should execute command "cd /vagrant && pwd"

  Scenario: raises error if commands are not array or splat
    Given I overwrite "Vagrantfile" with:
      """
      $LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)
      require 'vagrant-exec'

      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
        config.exec.commands true
      end
      """
    And I run `bundle exec vagrant up`
    Then the exit status should not be 0
    And the output should contain "commands should be an array of strings or splat"


  Scenario: can use custom directory for all commands
    Given I overwrite "Vagrantfile" with:
      """
      $LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)
      require 'vagrant-exec'

      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
        config.exec.commands '*', directory: '/tmp'
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec pwd`
    Then the exit status should be 0
    And SHH subprocess should execute command "cd /tmp && pwd"

  Scenario: can use custom directory for specific commands
    Given I overwrite "Vagrantfile" with:
      """
      $LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)
      require 'vagrant-exec'

      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
        config.exec.commands %w(pwd echo), directory: '/tmp'
      end
      """
    And I run `bundle exec vagrant up`
    Then SHH subprocess should execute command "cd /tmp && pwd"
    When I run `bundle exec vagrant exec echo 1`
    Then SHH subprocess should execute command "cd /tmp && echo 1"
    When I run `bundle exec vagrant exec env`
    Then SHH subprocess should execute command "cd /vagrant && env"

  Scenario: raises error if directory is improperly set
    Given I overwrite "Vagrantfile" with:
      """
      $LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)
      require 'vagrant-exec'

      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
        config.exec.commands '*', directory: true
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
        config.exec.commands '*', prepend: 'echo vagrant-exec &&'
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
        config.exec.commands %w(pwd echo), prepend: 'echo vagrant-exec &&'
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec pwd`
    Then SHH subprocess should execute command "cd /vagrant && echo vagrant-exec && pwd"
    When I run `bundle exec vagrant exec echo 1`
    Then SHH subprocess should execute command "cd /vagrant && echo vagrant-exec && echo 1"
    When I run `bundle exec vagrant exec env`
    Then SHH subprocess should execute command "cd /vagrant && env"

  Scenario: can combine prepended
    Given I overwrite "Vagrantfile" with:
      """
      $LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)
      require 'vagrant-exec'

      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
        config.exec.commands %w(pwd echo), prepend: 'echo vagrant-exec1 &&'
        config.exec.commands %w(pwd), prepend: 'echo vagrant-exec2 &&'
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec pwd`
    Then SHH subprocess should execute command "cd /vagrant && echo vagrant-exec1 && echo vagrant-exec2 && pwd"

  Scenario: raises error if prepend is improperly set
    Given I overwrite "Vagrantfile" with:
      """
      $LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)
      require 'vagrant-exec'

      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
        config.exec.commands '*', prepend: true
      end
      """
    When I run `bundle exec vagrant up`
    Then the exit status should not be 0
    And the output should contain "prepend should be a string"


  Scenario: can export environment variables for all commands
    Given I overwrite "Vagrantfile" with:
      """
      $LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)
      require 'vagrant-exec'

      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
        config.exec.commands '*', env: { 'TEST1' => true, 'TEST2' => false }
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec pwd`
    Then the exit status should be 0
    And SHH subprocess should execute command "cd /vagrant && export TEST1=true && export TEST2=false && pwd"

  Scenario: can export environment variables for specific commands
    Given I overwrite "Vagrantfile" with:
      """
      $LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)
      require 'vagrant-exec'

      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
        config.exec.commands %w(pwd echo), env: { 'TEST1' => true, 'TEST2' => false }
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec pwd`
    Then SHH subprocess should execute command "cd /vagrant && export TEST1=true && export TEST2=false && pwd"
    When I run `bundle exec vagrant exec echo 1`
    Then SHH subprocess should execute command "cd /vagrant && export TEST1=true && export TEST2=false && echo 1"
    When I run `bundle exec vagrant exec env`
    Then SHH subprocess should execute command "cd /vagrant && env"

  Scenario: can combine environment variables
    Given I overwrite "Vagrantfile" with:
      """
      $LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)
      require 'vagrant-exec'

      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
        config.exec.commands %w(pwd echo), env: { 'TEST1' => true, 'TEST2' => false }
        config.exec.commands %w(pwd), env: { 'TEST3' => false }
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec pwd`
    Then SHH subprocess should execute command "cd /vagrant && export TEST1=true && export TEST2=false && export TEST3=false && pwd"
    When I run `bundle exec vagrant exec echo 1`
    Then SHH subprocess should execute command "cd /vagrant && export TEST1=true && export TEST2=false && echo 1"

  Scenario: raises error if environment variables are improperly set
    Given I overwrite "Vagrantfile" with:
      """
      $LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)
      require 'vagrant-exec'

      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
        config.exec.commands '*', env: true
      end
      """
    When I run `bundle exec vagrant up`
    Then the exit status should not be 0
    And the output should contain "env should be a hash"
