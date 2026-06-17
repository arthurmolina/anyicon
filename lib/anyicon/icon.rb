# frozen_string_literal: true

require "net/http"
require "nokogiri"
require "fileutils"

module Anyicon
  # The Icon class is responsible for managing the rendering of icons from various
  # collections available on GitHub. It handles downloading and caching of icons
  # to ensure they are available for use in a Ruby on Rails application.
  #
  # Example usage:
  #
  #   icon = Anyicon::Icon.new(icon: 'fontawesome_regular:address-book')
  #   icon.render
  #
  # The class supports additional properties that can be passed in to customize
  # the SVG elements.
  class Icon < Anyicon::Common
    # Initializes a new Icon instance.
    #
    # @param icon [String] a comma-separated string of icon names, each in the format 'collection:name'
    # @param props [Hash] additional properties to apply to the SVG element
    ALLOWED_ATTRIBUTES = %w[
      class id style width height viewBox fill stroke
      stroke-width opacity transform title aria-label aria-hidden role
    ].freeze

    DATA_ATTRIBUTE_PATTERN = /\Adata-[\w-]+\z/

    def initialize(icon = nil, **props)
      super()
      @icons = (icon || props[:icon]).to_s.split(",").map { |i| i.split(":") }
      @icons.reject! { |i| i.length < 2 }
      @props = props.select { |key, _| allowed_attribute?(key) }
    end

    # Renders the SVG content for the specified icons.
    #
    # @return [String] the HTML-safe SVG content
    def render
      parts = @icons.map do |icon|
        ensure_icon_exists(icon)
        svg_content(icon)
      end
      ActiveSupport::SafeBuffer.new(parts.join)
    end

    private

    # Retrieves the collections configuration.
    #
    # @return [Hash] the collections configuration
    def collections
      @collections ||= Anyicon.configuration.collections
    end

    # Checks if an attribute key is allowed on the SVG element.
    #
    # @param key [Symbol, String] the attribute key
    # @return [Boolean]
    def allowed_attribute?(key)
      name = key.to_s
      ALLOWED_ATTRIBUTES.include?(name) || name.match?(DATA_ATTRIBUTE_PATTERN)
    end

    # Sanitizes an icon name component to prevent path traversal.
    #
    # @param name [String] the raw icon name component
    # @return [String] the sanitized name
    def sanitize_name(name)
      File.basename(name.to_s.gsub(/[^a-zA-Z0-9_\-]/, ""))
    end

    # Ensures the specified icon exists by downloading it if necessary.
    #
    # @param icon [Array] the collection and name of the icon
    def ensure_icon_exists(icon)
      return if File.exist?(icon_path(icon))

      download_icon(icon)
    end

    # Downloads the specified icon from the configured collection.
    #
    # @param icon [Array] the collection and name of the icon
    def download_icon(icon)
      url = icon_url(icon)
      return unless url

      FileUtils.mkdir_p(icon_path(icon).dirname)
      response = fetch(url)
      File.write(icon_path(icon), response.body) if response.is_a?(Net::HTTPSuccess)
    rescue ActionView::Template::Error, Net::HTTPError, Net::HTTPClientException => e
      ::Rails.logger.error "AnyIcon: Failed to download icon: #{e.message} (#{url})"
    end

    # Returns the local file path for the specified icon.
    #
    # @param icon [Array] the collection and name of the icon
    # @return [Pathname] the path to the icon file
    def icon_path(icon)
      ::Rails.root.join("app", "assets", "images", "icons", sanitize_name(icon[0]), "#{sanitize_name(icon[1])}.svg")
    end

    # Constructs the URL to download the specified icon.
    #
    # @param icon [Array] the collection and name of the icon
    # @return [String, nil] the URL to download the icon, or nil if the collection is not configured
    def icon_url(icon)
      collection_key = sanitize_name(icon[0]).to_sym
      return nil unless collections.key?(collection_key)

      [ "https://github.com/", collections[collection_key][:repo], "/raw/", collections[collection_key][:branch], "/",
       collections[collection_key][:path], "/", sanitize_name(icon[1]), ".svg" ].join("")
    end

    # Returns the cached raw SVG content for the specified icon.
    #
    # @param icon [Array] the collection and name of the icon
    # @return [String, nil] the raw SVG file content, or nil if file doesn't exist
    def cached_svg(icon)
      path = icon_path(icon)
      return nil unless File.file?(path)

      self.class.svg_cache[path.to_s] ||= File.read(path)
    end

    # Reads and customizes the SVG content for the specified icon.
    #
    # @param icon [Array] the collection and name of the icon
    # @return [String] the customized SVG content
    def svg_content(icon)
      raw = cached_svg(icon)
      return "" unless raw

      doc = Nokogiri::HTML::DocumentFragment.parse(raw)
      svg = doc.at_css "svg"

      @props.each do |key, value|
        value = "#{value} #{icon[-2..].join(' ')}" if key == :class && icon.count > 2

        svg[key.to_s] = value
      end

      doc.to_html
    end

    class << self
      # Renders the SVG content for the specified icons.
      #
      # @param kwargs [Hash] the parameters for initializing an Icon instance
      # @return [String] the HTML-safe SVG content
      def render(*args, **kwargs)
        new(*args, **kwargs).render
      end

      # In-memory cache for raw SVG file contents, keyed by file path.
      # Avoids repeated File.read + disk I/O for the same icon.
      #
      # @return [Hash] the SVG cache
      def svg_cache
        @svg_cache ||= {}
      end

      # Clears the in-memory SVG cache.
      def clear_cache!
        @svg_cache = {}
      end
    end
  end
end
