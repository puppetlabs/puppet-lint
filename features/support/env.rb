require 'aruba/cucumber'

require 'rspec'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

RSpec::Matchers.define :have_errors do |expected|
  match do |actual|
    actual.split("\n").count { |line| line.include?('ERROR') } == expected
  end

  diffable
end

RSpec::Matchers.define :have_warnings do |expected|
  match do |actual|
    actual.split("\n").count { |line| line.include?('WARNING') } == expected
  end

  diffable
end
