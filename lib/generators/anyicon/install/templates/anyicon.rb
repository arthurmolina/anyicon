# frozen_string_literal: true

Anyicon.configure do |config|
  ##
  # You can set the icon collections here.
  # Each collection should have a repository, path, and branch specified.
  #
  # Example:
  #
  # config.collections = {
  #   custom_collection: {
  #     repo: 'user/repo',
  #     path: 'path/to/icons',
  #     branch: 'main'
  #   }
  # }
  #

  config.collections = {
    # Add your icon collections here
    # Example:
    # fontawesome_regular: {
    #   repo: 'FortAwesome/Font-Awesome',
    #   path: 'svgs/regular',
    #   branch: 'master'
    # },
    # heroicons_solid: {
    #   repo: 'tailwindlabs/heroicons',
    #   path: 'optimized/24/solid',
    #   branch: 'master'
    # }
  }
end
