@no-clobber
Feature: vagrant-exec binstubs
  In order to easily integrate vagrant-exec into editors/IDEs
  And significantly increase speed of executing commands in VM
  As a user
  I want to be able to generate binstubs for configured commands
  Which use plan SSH

  @posix
  Scenario: generates binstubs for each configured command
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure('2') do |config|
        config.vm.box = 'hashicorp/precise64'
        config.exec.commands 'echo', directory: '/tmp'
        config.exec.commands %w[pwd echo], prepend: 'test -d . &&', env: {'TEST' => 1}
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

  @windows
  Scenario: generates binstubs for each configured command
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure('2') do |config|
        config.vm.box = 'ferventcoder/win7pro-x64-nocm-lite'
        config.vm.guest = :windows
        config.exec.commands 'echo', directory: 'C:\Windows'
        config.exec.commands %w[dir echo], prepend: 'echo %TEST% &', env: {'TEST' => 1}
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
    And the mode of filesystem object "bin/dir" should match "755"
    And the file "bin/echo" should contain exactly:

      """
      #!/bin/bash
      ssh -F .vagrant/ssh_config -q -t default "cmd /c 'cd C:\tmp && set TEST=1 && echo %TEST% & echo $@'"

      """
    And the file "bin/dir" should contain exactly:
      """
      #!/bin/bash
      ssh -F .vagrant/ssh_config -q -t default "cmd /c 'cd C:\tmp && set TEST=1 && echo %TEST% & dir $@'"

      """
    When I run `bin/echo test`
    Then the exit status should be 0
    And the output should contain "test"
    When I run `bin/dir`
    Then the exit status should be 0
    And the output should contain "/vagrant"

  Scenario: dumps vagrant ssh-config to file for default box
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure('2') do |config|
        config.vm.box = 'hashicorp/precise64'
        config.exec.commands 'echo'
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec --binstubs`
    Then a file named ".vagrant/ssh_config" should exist
    And the file ".vagrant/ssh_config" should contain result of vagrant ssh-config

  Scenario: dumps vagrant ssh-config to file for defined box
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure('2') do |config|
        config.vm.box = 'hashicorp/precise64'
        config.vm.define 'vagrant'
        config.exec.commands 'echo'
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec --binstubs`
    Then a file named ".vagrant/ssh_config" should exist
    And the file ".vagrant/ssh_config" should contain result of vagrant ssh-config

  @posix
  Scenario: respects configured shell
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure('2') do |config|
        config.vm.box = 'hashicorp/precise64'
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

  Scenario: respects configured binstubs directory
    Given I write to "Vagrantfile" with:
    """
    Vagrant.configure('2') do |config|
      config.vm.box = 'hashicorp/precise64'
      config.exec.binstubs_path = 'vbin'
      config.exec.commands 'test'
    end
    """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec --binstubs`
    Then the output should contain "Generated binstub for test in vbin/test."
    And a file named "vbin/test" should exist
    But a file named "bin/test" should not exist

  Scenario: escapes double-quotes in command
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure('2') do |config|
        config.vm.box = 'hashicorp/precise64'
        config.exec.commands 'echo', env: {'TEST' => 'one two'}
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
        config.vm.box = 'hashicorp/precise64'
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
        config.vm.box = 'hashicorp/precise64'
        config.exec.commands '*', env: {'TEST' => 'one two'}
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec --binstubs`
    Then the exit status should be 0
    And the output should contain "No commands to generate binstubs for."

  Scenario: raises if vagrant is not up
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure('2') do |config|
        config.vm.box = 'hashicorp/precise64'
      end
      """
    And I run `bundle exec vagrant halt`
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
