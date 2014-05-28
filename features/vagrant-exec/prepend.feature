@no-clobber
Feature: vagrant-exec prepend
  In order to automatically prepend with custom command
  Commands I execute using vagrant-exec
  As a user
  I should be able to specify it in Vagrantfile

  Scenario: prepends all commands
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
        config.exec.commands '*', prepend: 'echo vagrant-exec &&'
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec pwd`
    Then the exit status should be 0
    And SHH subprocess should execute command "cd /vagrant && echo vagrant-exec && pwd"

  Scenario: prepends specific commands
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
        config.exec.commands 'cmd', prepend: 'echo vagrant-exec1 &&'
        config.exec.commands %w(pwd echo), prepend: 'echo vagrant-exec2 &&'
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec cmd`
    Then SHH subprocess should execute command "cd /vagrant && echo vagrant-exec1 && cmd"
    When I run `bundle exec vagrant exec pwd`
    Then SHH subprocess should execute command "cd /vagrant && echo vagrant-exec2 && pwd"
    When I run `bundle exec vagrant exec echo 1`
    Then SHH subprocess should execute command "cd /vagrant && echo vagrant-exec2 && echo 1"
    When I run `bundle exec vagrant exec env`
    Then SHH subprocess should execute command "cd /vagrant && env"

  Scenario: combines prepended
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
        config.exec.commands '*', prepend: 'echo vagrant-exec1 &&'
        config.exec.commands 'pwd', prepend: 'echo vagrant-exec2 &&'
        config.exec.commands %w(pwd echo), prepend: 'echo vagrant-exec3 &&'
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec pwd`
    Then SHH subprocess should execute command "cd /vagrant && echo vagrant-exec1 && echo vagrant-exec2 && echo vagrant-exec3 && pwd"
    When I run `bundle exec vagrant exec echo 1`
    Then SHH subprocess should execute command "cd /vagrant && echo vagrant-exec1 && echo vagrant-exec3 && echo 1"
    When I run `bundle exec vagrant exec env`
    Then SHH subprocess should execute command "cd /vagrant && echo vagrant-exec1 && env"

  Scenario: adds prepend only in the end
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
        config.exec.commands 'pwd', prepend: 'bundle exec'
        config.exec.commands 'pwd', env: { 'TEST' => true }
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec pwd`
    Then SHH subprocess should execute command "cd /vagrant && export TEST=true && bundle exec pwd"
