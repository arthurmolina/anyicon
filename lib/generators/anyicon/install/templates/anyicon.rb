# frozen_string_literal: true

Anyicon.configure do |config|
  ##
  # You can set the icon collections here.
  # Each collection should have a repository, path, and branch specified.
  #
  # Example:
  #
  # config.add_collections(
  #   custom_collection: {
  #     repo: 'user/repo',
  #     path: 'path/to/icons',
  #     branch: 'main'
  #   }
  # )
  #

  ##
  # Optional: Set a GitHub personal access token to avoid API rate limits
  # (60 requests/hour unauthenticated vs 5,000/hour authenticated).
  #
  # config.github_token = ENV["GITHUB_TOKEN"]
  #
end
