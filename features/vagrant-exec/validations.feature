@no-clobber
Feature: vagrant-exec validations
  In order to avoid configuration mistakes for vagrant-exec commands
  As a user
  I should see proper validation errors

  Background:
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure('2') do |config|
        config.vm.box = 'vagrant_exec'
        config.exec.commands true, directory: nil, prepend: true, env: 0
      end
      """

  Scenario: raises error if command is not string or array of strings
    When I run `bundle exec vagrant up`
    Then the exit status should not be 0
    And the output should contain "Commands should be String or Array<String>, received: true"

  Scenario: raises error if directory is improperly set
    When I run `bundle exec vagrant up`
    Then the exit status should not be 0
    And the output should contain ":directory should be String, received: nil"

  Scenario: raises error if prepend is improperly set
    When I run `bundle exec vagrant up`
    Then the exit status should not be 0
    And the output should contain ":prepend should be String, received: true"

  Scenario: raises error if environment variables are improperly set
    When I run `bundle exec vagrant up`
    Then the exit status should not be 0
    And the output should contain ":env should be Hash, received: 0"
