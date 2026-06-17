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
    ALLOWED_HOSTS = %w[github.com raw.githubusercontent.com objects.githubusercontent.com api.github.com].freeze

    # Fetches the content from the given URL, following redirects if necessary.
    #
    # @param url [String] the URL to fetch
    # @param limit [Integer] the maximum number of redirects to follow (default is 10)
    # @return [Net::HTTPResponse] the HTTP response
    # @raise [Net::HTTPError] if the number of redirects exceeds the limit or another HTTP error occurs
    def fetch(url, limit = 10)
      raise Net::HTTPError.new("Too many HTTP redirects", nil) if limit.zero?
      return nil if url.nil?

      uri = URI.parse(URI::RFC2396_PARSER.escape(url))
      unless uri.is_a?(URI::HTTPS) && ALLOWED_HOSTS.include?(uri.host)
        raise Net::HTTPError.new("Blocked request to disallowed host: #{uri.host}", nil)
      end

      request = Net::HTTP::Get.new(uri)
      token = Anyicon.configuration.github_token
      request["Authorization"] = "token #{token}" if token

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      case response
      when Net::HTTPSuccess then response
      when Net::HTTPRedirection then fetch(response["location"], limit - 1)
      else
        response.error!
      end
    end
  end
end
