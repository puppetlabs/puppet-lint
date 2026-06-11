source 'https://rubygems.org'

gemspec

gemsource_puppetcore = if ENV['PUPPET_FORGE_TOKEN']
  'https://rubygems-puppetcore.puppet.com'
else
  ENV['GEM_SOURCE_PUPPETCORE'] || 'https://rubygems.org'
end

group :test do
  gem 'rake'
  gem 'rspec-its', '~> 1.0'

  gem 'rspec', '~> 3.0'
  gem 'json'

  gem 'rspec-json_expectations', '~> 1.4'
  gem 'simplecov', :require => false
  gem 'simplecov-console', :require => false
end

group :acceptance do
  gem 'serverspec'
  gem 'puppetlabs_spec_helper'
  gem 'puppet_litmus'
  gem 'bolt', ENV.fetch('BOLT_GEM_VERSION', nil), source: gemsource_puppetcore
end

group :development do
    gem 'github_changelog_generator', '~> 1.15.0', require: false
    gem 'faraday-retry', require: false
    gem 'pry', require: false
    gem 'pry-byebug', require: false
    gem 'pry-stack_explorer', require: false
end

group :rubocop do
    gem 'rubocop', '~> 1.64.0', require: false
    gem 'rubocop-rspec', '~> 3.0', require: false
    gem 'rubocop-performance', '~> 1.16', require: false
end
