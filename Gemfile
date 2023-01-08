# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

gem 'rspec', '~> 3.7'
gem 'rubocop', '~> 1.41', '>= 1.41.1'
gem 'simplecov', '~> 0.10', '< 0.18'

group :test do
  gem 'pry', '~> 0.14.1'
  gem 'vcr', '~> 6.1.0'
  gem 'webmock', '~> 3.18.1'
end
