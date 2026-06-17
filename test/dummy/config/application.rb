# frozen_string_literal: true

require File.expand_path("boot", __dir__)

# require "rails/all"

require "rails"
Bundler.require(*Rails.groups)

module Dummy
  class Application < Rails::Application
    config.encoding = "utf-8"

    # replacement for environments/*.rb
    config.active_support.deprecation = :stderr
    config.eager_load = false
    config.active_support.cache_format_version = 7.1
    config.active_support.test_order = begin
      :random
    rescue StandardError
      nil
    end
  end
end
