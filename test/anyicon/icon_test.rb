# frozen_string_literal: true

require 'test_helper'
require 'anyicon/icon'

module Anyicon
  class IconTest < ActiveSupport::TestCase
    def setup
      @icon_name = 'fontawesome_regular:address-book'
      @icon = Anyicon::Icon.new(icon: @icon_name)
    end

    def test_render
      assert_includes @icon.render, '<svg'
    end

    def test_downloads_and_caches_icon_if_not_exist
      @icon.stubs(:ensure_icon_exists).returns(true)
      assert_nothing_raised { @icon.render }
    end

    def test_raises_error_if_icon_does_not_exist_and_cannot_be_downloaded
      @icon.stubs(:ensure_icon_exists).raises(StandardError)
      assert_raises(StandardError) { @icon.render }
    end
  end
end
