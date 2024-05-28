# frozen_string_literal: true

module Anyicon
  # The Common class provides utility methods that can be used across the Anyicon gem.
  # This class includes methods for making HTTP requests, handling redirects, and fetching
  # content from specified URLs. It ensures that the HTTP requests follow redirects up to
  # a specified limit to prevent infinite loops.
  #
  # Example usage:
  #
  #   common = Anyicon::Common.new
  #   response = common.fetch('https://example.com')
  #   puts response.body if response.is_a?(Net::HTTPSuccess)
  class Common
    # Fetches the content from the given URL, following redirects if necessary.
    #
    # @param url [String] the URL to fetch
    # @param limit [Integer] the maximum number of redirects to follow (default is 10)
    # @return [Net::HTTPResponse] the HTTP response
    # @raise [Net::HTTPError] if the number of redirects exceeds the limit or another HTTP error occurs
    def fetch(url, limit = 10)
      raise Net::HTTPError, 'Too many HTTP redirects' if limit.zero?
      return nil if url.nil?

      uri = URI.parse(URI::DEFAULT_PARSER.escape(url))
      response = Net::HTTP.get_response(uri)

      case response
      when Net::HTTPSuccess then response
      when Net::HTTPRedirection then fetch(response['location'], limit - 1)
      else
        response.error!
      end
    end
  end
end
