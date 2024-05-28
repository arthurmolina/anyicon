# frozen_string_literal: true

module Anyicon
  # The Engine class is responsible for integrating the Anyicon gem with a Ruby on Rails application.
  # It inherits from Rails::Engine, which allows it to hook into the Rails framework and provide
  # the necessary configurations and initializations for the gem.
  #
  # The engine ensures that icons are precompiled as part of the Rails asset pipeline, making them
  # available for use in the application's views.
  #
  # Example usage in a Rails application:
  #
  #   # In a Rails initializer (config/initializers/anyicon.rb)
  #   Anyicon.configure do |config|
  #     config.collections = {
  #       custom_collection: { repo: 'user/repo', path: 'path/to/icons', branch: 'main' }
  #     }
  #   end
  #
  # This configuration allows the application to specify additional icon collections that can be
  # used with the Anyicon helper methods.
  module Rails
    class Engine < ::Rails::Engine
    end
  end
end
