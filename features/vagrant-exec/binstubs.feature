@no-clobber
Feature: vagrant-exec binstubs
  In order to easily integrate vagrant-exec into editors/IDEs
  And significantly increase speed of executing commands in VM
  As a user
  I want to be able to generate binstubs for configured commands
  Which use plan SSH

  Scenario: generates binstubs for each configured command
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
        config.exec.commands 'echo', directory: '/tmp'
        config.exec.commands %w(pwd echo), prepend: 'test -d . &&', env: { 'TEST' => 1 }
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec --binstubs`
    Then the exit status should be 0
    And the output should contain "Generated binstub for echo in bin/echo."
    And the output should contain "Generated binstub for pwd in bin/pwd."
    And a file named "bin/echo" should exist
    And a file named "bin/pwd" should exist
    And the mode of filesystem object "bin/echo" should match "755"
    And the mode of filesystem object "bin/pwd" should match "755"
    And the file "bin/echo" should contain exactly:
      """
      #!/bin/bash
      ssh -F .vagrant/ssh_config -q -t default "bash -l -c 'cd /tmp && export TEST=1 && test -d . && echo $@'"

      """
    And the file "bin/pwd" should contain exactly:
      """
      #!/bin/bash
      ssh -F .vagrant/ssh_config -q -t default "bash -l -c 'cd /vagrant && export TEST=1 && test -d . && pwd $@'"

      """
    When I run `bin/echo test`
    Then the exit status should be 0
    And the output should contain "test"
    When I run `bin/pwd`
    Then the exit status should be 0
    And the output should contain "/vagrant"

  Scenario: dumps vagrant ssh-config to file
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
        config.exec.commands 'echo'
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec --binstubs`
    Then a file named ".vagrant/ssh_config" should exist
    And the file ".vagrant/ssh_config" should contain result of vagrant ssh-config

  Scenario: respects configured shell
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
        config.ssh.shell = 'zsh -l'
        config.exec.commands 'echo'
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec --binstubs`
    Then the file "bin/echo" should contain exactly:
      """
      #!/bin/bash
      ssh -F .vagrant/ssh_config -q -t default "zsh -l -c 'cd /vagrant && echo $@'"

      """

  Scenario: escapes double-quotes in command
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
        config.exec.commands 'echo', env: { 'TEST' => 'one two' }
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec --binstubs`
    Then the file "bin/echo" should contain exactly:
      """
      #!/bin/bash
      ssh -F .vagrant/ssh_config -q -t default "bash -l -c 'cd /vagrant && export TEST=\"one two\" && echo $@'"

      """

  Scenario: skips if no commands are configured
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec --binstubs`
    Then the exit status should be 0
    And the output should contain "No commands to generate binstubs for."

  Scenario: skips if only splat commands are configured
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
        config.exec.commands '*', env: { 'TEST' => 'one two' }
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec --binstubs`
    Then the exit status should be 0
    And the output should contain "No commands to generate binstubs for."

  Scenario: raises if vagrant is not upped
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
      end
      """
    When I run `bundle exec vagrant exec --binstubs`
    Then the exit status should not be 0
    And the stderr should contain:
      """
      The provider for this Vagrant-managed machine is reporting that it
      is not yet ready for SSH. Depending on your provider this can carry
      different meanings. Make sure your machine is created and running and
      try again. Additionally, check the output of `vagrant status` to verify
      that the machine is in the state that you expect. If you continue to
      get this error message, please view the documentation for the provider
      you're using.
      """
