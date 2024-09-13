require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'github_changelog_generator/task'
require 'puppet-lint/version'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'

begin
  require 'github_changelog_generator/task'
rescue LoadError
  # Gem not present
else
  GitHubChangelogGenerator::RakeTask.new(:changelog) do |config|
    version = PuppetLint::VERSION
    config.user = 'puppetlabs'
    config.project = 'puppet-lint'
    config.since_tag = '2.5.0'
    config.future_release = version.to_s
    config.exclude_labels = %w[duplicate question invalid wontfix release-pr documentation]
    config.enhancement_labels = %w[feature]
  end
end

begin
  require 'puppet_litmus/rake_tasks'
rescue LoadError
  # Gem not present
end

namespace :spec do
  desc 'Run RSpec code examples with coverage collection'
  task :coverage do
      ENV['COVERAGE'] = 'yes'
      Rake::Task['spec'].execute
  end
end

RSpec::Core::RakeTask.new(:spec) do |t|
  t.exclude_pattern = 'spec/acceptance/**/*_spec.rb'
end

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "--format pretty" # Any valid command line option can go here.
end

task default: [:spec, :features]
