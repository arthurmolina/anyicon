# frozen_string_literal: true

require 'net/http'
require 'json'
require 'fileutils'

module Anyicon
  # The Collection class is responsible for managing icon collections
  # from various repositories. It provides functionality to list and
  # download all icons from a specified collection.
  #
  # Example usage:
  #
  #   collection = Anyicon::Collection.new(:fontawesome_regular)
  #   collection.list        # Lists all icons in the collection
  #   collection.download_all # Downloads all icons in the collection
  #
  # The class interacts with the configured collections in Anyicon::Configuration
  # to determine the repository, path, and branch for each collection.
  class Collection < Anyicon::Common
    # Initializes a new Collection instance for the specified collection.
    #
    # @param collection [Symbol] the name of the icon collection
    def initialize(collection)
      super()
      @collection = collection
    end

    # Lists all icons in the collection by fetching the directory contents from the repository.
    #
    # @return [Array<Hash>] a list of icons with their metadata
    def list
      response = fetch(collection_url)
      JSON.parse(response.body)
    end

    # Downloads all icons in the collection and saves them to the local file system.
    #
    # @return [void]
    def download_all
      count = 0
      list.each do |icon|
        count += 1
        download(icon)
      end
      puts "#{@collection}: #{count} downloads."
    end

    # Retrieves the configured collections from Anyicon.
    #
    # @return [Hash] the configured collections
    def collections
      @collections ||= Anyicon::Configuration.new.collections
    end

    private

    # Downloads a single icon and saves it to the local file system.
    #
    # @param icon [Hash] the metadata of the icon to download
    # @return [void]
    def download(icon)
      return if icon['download_url'].nil?
      return if File.exist?(icon_path(icon['name']))

      FileUtils.mkdir_p(icon_path(icon['name']).dirname)
      response = fetch(icon['download_url'])
      File.write(icon_path(icon['name']), response.body)
    rescue ActionView::Template::Error, ::OpenURI::HTTPError => e
      ::Rails.logger.error "AnyIcon: Failed to download icon: #{e.message}"
    end

    # Constructs the local file path for the specified icon.
    #
    # @param icon_name [String] the name of the icon
    # @return [Pathname] the path to the icon file
    def icon_path(icon_name)
      ::Rails.root.join('app', 'assets', 'images', 'icons', @collection.to_s, icon_name)
    end

    # Constructs the URL to fetch the icon collection directory contents from the repository.
    #
    # @return [String, nil] the URL to fetch the collection contents, or nil if the collection is not configured
    def collection_url
      return nil unless collections.keys.include?(@collection)

      [
        'https://api.github.com/repos/',
        collections[@collection][:repo],
        '/contents/',
        collections[@collection][:path]
      ].join('')
    end
  end
end
