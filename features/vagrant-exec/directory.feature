@no-clobber
Feature: vagrant-exec directory
  In order to change the working directory
  For commands I execute using vagrant-exec
  As a user
  I should be able to specify it in Vagrantfile

  Scenario: uses /vagrant as default directory
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec pwd`
    Then the exit status should be 0
    And SHH subprocess should execute command "cd /vagrant && pwd"

  Scenario: uses custom directory for all commands
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
        config.exec.commands '*', directory: '/tmp'
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec pwd`
    Then the exit status should be 0
    And SHH subprocess should execute command "cd /tmp && pwd"

  Scenario: uses custom directory for specific commands
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
        config.exec.commands %w(pwd echo), directory: '/tmp'
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec echo 1`
    Then SHH subprocess should execute command "cd /tmp && echo 1"
    When I run `bundle exec vagrant exec env`
    Then SHH subprocess should execute command "cd /vagrant && env"

