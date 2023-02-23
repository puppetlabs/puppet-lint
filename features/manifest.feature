Feature: With a manifest provided
  Scenario: containing one problem
    Given a file named "fail.pp" with:
    """
    # foo
    class test::foo { }
    """
    When I run `puppet-lint fail.pp`
    Then it has 1 error and 0 warnings

    Scenario: containing a control statement
      Given a file named "ignore.pp" with:
      """
      "test" # lint:ignore:double_quoted_strings
      """
      When I run `puppet-lint ignore.pp`
      Then it has 0 errors and 0 warnings

    Scenario: containing one warning
      Given a file named "test/manifests/warning.pp" with:
      """
      # foo
      define test::warning($foo='bar', $baz) { }
      """
      When I run `puppet-lint test/manifests/warning.pp`
      Then I should see 0 errors and 1 warning

    Scenario: containing two warnings
      Given a file named "test/manifests/two_warnings.pp" with:
      """
      # foo
      define test::two_warnings() {
        $var1-with-dash = 42
        $VarUpperCase   = false
      }
      """
      When I run `puppet-lint test/manifests/two_warnings.pp`
      Then I should see 0 errors and 2 warnings
