# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'anyicon/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = 'anyicon'
  spec.version = Anyicon::VERSION
  spec.authors = ['Arthur Molina']
  spec.email = ['arthurmolina@gmail.com']
  spec.homepage = 'https://github.com/arthurmolina/anyicon'
  spec.summary = 'Rails View Helpers for any icon collections.'
  spec.description = 'Ruby on Rails View Helpers for any icon collections that have github repository available.'
  spec.license = 'MIT'
  spec.require_paths = ['lib']

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.required_ruby_version = '>= 2.7'

  spec.add_dependency 'rails', '>= 5.2'

  spec.add_development_dependency 'appraisal'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-rails'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'standard'
end
