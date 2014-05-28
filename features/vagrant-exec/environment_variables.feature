@no-clobber
Feature: vagrant-exec environment variables
  In order to automatically set environment variables
  For commands I execute using vagrant-exec
  As a user
  I should be able to specify them in Vagrantfile

  Scenario: exports environment variables for all commands
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
        config.exec.commands '*', env: { 'TEST1' => true, 'TEST2' => false }
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec pwd`
    Then the exit status should be 0
    And SHH subprocess should execute command "cd /vagrant && export TEST1=true && export TEST2=false && pwd"

  Scenario: exports environment variables for specific commands
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
        config.exec.commands 'cmd', env: { 'TEST1' => 'yo' }
        config.exec.commands %w(pwd echo), env: { 'TEST2' => true, 'TEST3' => false }
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec cmd`
    Then SHH subprocess should execute command "cd /vagrant && export TEST1=yo && cmd"
    When I run `bundle exec vagrant exec pwd`
    Then SHH subprocess should execute command "cd /vagrant && export TEST2=true && export TEST3=false && pwd"
    When I run `bundle exec vagrant exec echo 1`
    Then SHH subprocess should execute command "cd /vagrant && export TEST2=true && export TEST3=false && echo 1"
    When I run `bundle exec vagrant exec env`
    Then SHH subprocess should execute command "cd /vagrant && env"

  Scenario: combines environment variables
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
        config.exec.commands '*', env: { 'TEST1' => true }
        config.exec.commands 'pwd', env: { 'TEST2' => false }
        config.exec.commands %w(pwd echo), env: { 'TEST3' => false }
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec pwd`
    Then SHH subprocess should execute command "cd /vagrant && export TEST1=true && export TEST2=false && export TEST3=false && pwd"
    When I run `bundle exec vagrant exec echo 1`
    Then SHH subprocess should execute command "cd /vagrant && export TEST1=true && export TEST3=false && echo 1"
    When I run `bundle exec vagrant exec env`
    Then SHH subprocess should execute command "cd /vagrant && export TEST1=true && env"

  Scenario: wraps values with spaces to quotes
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
        config.exec.commands 'pwd', env: { 'TEST' => 'one two' }
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec pwd`
    Then SHH subprocess should execute command "cd /vagrant && export TEST="one two" && pwd"
