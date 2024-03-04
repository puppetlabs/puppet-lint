Feature: Without a manifest provided
  Scenario: no arguments
    When I run `puppet-lint`
    Then the exit status should be 1

  Scenario: with --help
    When I run `puppet-lint --help`
    Then the exit status should be 0

  Scenario: with --help
    When I run `puppet-lint --version`
    Then the exit status should be 0
    # TODO: dynamically retrieve puppet-lint version
    And the output should contain "puppet-lint 3.0.1"
