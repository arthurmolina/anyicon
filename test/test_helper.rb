# frozen_string_literal: true

# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require File.expand_path('dummy/config/environment.rb', __dir__)
require 'rails/test_help'
require 'mocha/minitest'

Rails.backtrace_cleaner.remove_silencers!
