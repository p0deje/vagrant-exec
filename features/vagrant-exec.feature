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
    Given I have default Vagrantfile

  Scenario: uses /vagrant as default folder
    Given I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec pwd`
    Then the exit status should be 0
    And the output should contain "Executing single command on remote machine: cd /vagrant && pwd"

  Scenario: can use custom folder
    Given I set vagrant-exec folder to "/tmp"
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec pwd`
    Then the exit status should be 0
    And the output should contain "Executing single command on remote machine: cd /tmp && pwd"

  Scenario: raises error if folder is improperly set
    Given I set vagrant-exec folder to true
    And I run `bundle exec vagrant up`
    Then the exit status should not be 0
    And the output should contain "folder should be a string"

  Scenario: does not use bundler by default
    Given I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec pwd`
    Then the output should not contain "bundle exec"

  # we don't have bundler in box
  Scenario: can use bundler
    Given I set vagrant-exec bundler to true
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec pwd`
    Then the exit status should not be 0
    And the output should contain "Executing single command on remote machine: cd /vagrant && bundle exec pwd"

  Scenario: does not use bundler for bundle commands
    Given I set vagrant-exec bundler to true
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec bundle install`
    Then the output should contain "Executing single command on remote machine: cd /vagrant && bundle install"

  Scenario: raises error if bundler is improperly set
    Given I set vagrant-exec bundler to "true"
    When I run `bundle exec vagrant up`
    Then the exit status should not be 0
    And the output should contain "bundler should be boolean"

  Scenario: can export environment variables
    Given I set vagrant-exec env with the following values:
      | key   | value |
      | TEST1 | true  |
      | TEST2 | false |
    And I run `bundle exec vagrant up`
    When I run `bundle exec vagrant exec pwd`
    Then the exit status should be 0
    And the output should contain "Executing single command on remote machine: cd /vagrant && export TEST1=true && export TEST2=false && pwd"

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
    Then the output should contain "Executing single command on remote machine: cd /vagrant && <cmd>"
    Examples:
      | cmd                 |
      | cwd .               |
      | cwd ~               |
      | cwd -h              |
      | cwd --blah          |
      | cwd -h blah -v blah |
