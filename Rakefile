require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'github_changelog_generator/task'
require 'puppetlabs/puppet-lint/version'
require 'rspec/core/rake_task'
require 'puppetlabs_spec_helper/tasks/fixtures'

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

RSpec::Core::RakeTask.new(:spec) do |t|
  t.exclude_pattern = 'spec/acceptance/**/*_spec.rb'
end

desc 'Run acceptance tests'
task :acceptance do
  Rake::Task['litmus:acceptance:localhost'].invoke
end
