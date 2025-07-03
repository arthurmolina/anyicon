# frozen_string_literal: true

require 'net/http'
require 'nokogiri'
require 'fileutils'

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
    def initialize(icon:, **props)
      super()
      @icons = icon.to_s.split(',').map { |i| i.split(':') }
      @props = props
    end

    # Renders the SVG content for the specified icons.
    #
    # @return [String] the HTML-safe SVG content
    def render
      result = ''.html_safe
      @icons.each do |icon|
        ensure_icon_exists(icon)
        result.concat(svg_content(icon).html_safe)
      end
      result
    end

    private

    # Retrieves the collections configuration.
    #
    # @return [Hash] the collections configuration
    def collections
      @collections ||= Anyicon.configuration.collections
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
      ::Rails.root.join('app', 'assets', 'images', 'icons', icon[0], "#{icon[1]}.svg")
    end

    # Constructs the URL to download the specified icon.
    #
    # @param icon [Array] the collection and name of the icon
    # @return [String, nil] the URL to download the icon, or nil if the collection is not configured
    def icon_url(icon)
      return nil unless collections.keys.include?(icon[0].to_sym)

      ['https://github.com/', collections[icon[0].to_sym][:repo], '/raw/', collections[icon[0].to_sym][:branch], '/',
       collections[icon[0].to_sym][:path], '/', icon[1], '.svg'].join('')
    end

    # Reads and customizes the SVG content for the specified icon.
    #
    # @param icon [Array] the collection and name of the icon
    # @return [String] the customized SVG content
    def svg_content(icon)
      return '' unless File.file?(icon_path(icon))

      svg_content = File.read(icon_path(icon))
      doc = Nokogiri::HTML::DocumentFragment.parse(svg_content)
      svg = doc.at_css 'svg'

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
      def render(**kwargs)
        new(**kwargs).render
      end
    end
  end
end
