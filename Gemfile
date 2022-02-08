source 'https://rubygems.org'

gemspec

group :test do
  gem 'rake', '~> 13.0'
  gem 'rspec-its', '~> 1.0'
  gem 'rspec-collection_matchers', '~> 1.0'

  gem 'rspec', '~> 3.0'
  gem 'json'

  gem 'rspec-json_expectations', '>= 1.4'

  gem 'rubocop', '0.49.1'
  gem 'simplecov', :require => false if ENV['COVERAGE'] == 'yes'
end

group :development do
  gem 'github_changelog_generator', :require => false
  gem 'pry'
end
