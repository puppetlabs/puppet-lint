Then('I should see {int} error(s) and {int} warning(s)') do |error, warning|
  expected_exit = error.zero? ? 0 : 1
  step "the exit status should be #{expected_exit}"

  output = last_command_started.public_send :stdout, wait_for_io: 0
  expect(output).to have_errors(error).and(have_warnings(warning))
end
