# frozen_string_literal: true
require 'rails/generators'

module Anyicon
  module Generators
    # The InstallGenerator class is a Rails generator that sets up the initial configuration
    # for the Anyicon gem. This generator copies a template configuration file into the
    # Rails application's initializers directory, allowing the user to customize the icon
    # collections and other settings.
    #
    # Example usage:
    #
    #   # Run the generator from the command line
    #   rails generate anyicon:install
    #
    # This will copy the `anyicon.rb` template to `config/initializers/anyicon.rb` in your
    # Rails application.
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.join(__dir__, 'templates')
      desc "This generator installs AnyIcon"

      # Copies the anyicon configuration template to the initializers directory.
      #
      # @return [void]
      def copy_config
        template 'anyicon.rb', 'config/initializers/anyicon.rb'
      end
    end
  end
end
