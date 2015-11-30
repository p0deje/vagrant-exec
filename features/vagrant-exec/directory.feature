@no-clobber
Feature: vagrant-exec directory
  In order to change the working directory
  For commands I execute using vagrant-exec
  As a user
  I should be able to specify it in Vagrantfile

  @posix
  Scenario: uses /vagrant as default directory
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure('2') do |config|
        config.vm.box = 'hashicorp/precise64'
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec pwd`
    Then the exit status should be 0
    And SHH subprocess should execute command "cd /vagrant && pwd"

  @windows
  Scenario: uses C:\vagrant as default directory
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure('2') do |config|
        config.vm.box = 'ferventcoder/win7pro-x64-nocm-lite'
        config.vm.guest = :windows
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec dir`
    Then the exit status should be 0
    And SHH subprocess should execute command "cd C:\vagrant && dir"

  @posix
  Scenario: uses custom directory for all commands
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure('2') do |config|
        config.vm.box = 'hashicorp/precise64'
        config.exec.commands '*', directory: '/tmp'
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec pwd`
    Then the exit status should be 0
    And SHH subprocess should execute command "cd /tmp && pwd"

  @windows
  Scenario: uses custom directory for all commands
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure('2') do |config|
        config.vm.box = 'ferventcoder/win7pro-x64-nocm-lite'
        config.vm.guest = :windows
        config.exec.commands '*', directory: 'C:\Windows'
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec dir`
    Then the exit status should be 0
    And SHH subprocess should execute command "cd C:\Windows && dir"

  @posix
  Scenario: uses custom directory for specific commands
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure('2') do |config|
        config.vm.box = 'hashicorp/precise64'
        config.exec.commands %w[pwd echo], directory: '/tmp'
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec echo 1`
    Then SHH subprocess should execute command "cd /tmp && echo 1"
    When I run `bundle exec vagrant exec env`
    Then SHH subprocess should execute command "cd /vagrant && env"

  @windows
  Scenario: uses custom directory for specific commands
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure('2') do |config|
        config.vm.box = 'ferventcoder/win7pro-x64-nocm-lite'
        config.vm.guest = :windows
        config.exec.commands %w[dir echo], directory: 'C:\Windows'
      end
      """
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec echo 1`
    Then SHH subprocess should execute command "cd C:\Windows && echo 1"
    When I run `bundle exec vagrant exec env`
    Then SHH subprocess should execute command "cd C:\vagrant && env"
