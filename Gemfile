# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "rails", "~> 7.2"

gemspec

group :development do
  gem "guard", "~> 2.20"
  gem "guard-minitest", "~> 3.0"
end

group :test do
  gem "mocha"
end

group :development, :test do
  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
end
