# frozen_string_literal: true

require "test_helper"
require "anyicon/icon"
require "anyicon/common"

module Anyicon
  class PathTraversalTest < ActiveSupport::TestCase
    def test_sanitize_name_strips_path_traversal
      icon = Anyicon::Icon.new("fontawesome_regular:address-book")
      sanitize = icon.send(:sanitize_name, "../../etc/passwd")
      assert_equal "etcpasswd", sanitize
    end

    def test_sanitize_name_strips_slashes
      icon = Anyicon::Icon.new("fontawesome_regular:address-book")
      sanitize = icon.send(:sanitize_name, "foo/bar/baz")
      assert_equal "foobarbaz", sanitize
    end

    def test_sanitize_name_strips_dots
      icon = Anyicon::Icon.new("fontawesome_regular:address-book")
      sanitize = icon.send(:sanitize_name, "../../../secret")
      assert_equal "secret", sanitize
    end

    def test_sanitize_name_preserves_valid_characters
      icon = Anyicon::Icon.new("fontawesome_regular:address-book")
      sanitize = icon.send(:sanitize_name, "my-icon_name")
      assert_equal "my-icon_name", sanitize
    end

    def test_icon_path_is_contained_within_assets
      icon = Anyicon::Icon.new("../../etc:passwd")
      path = icon.send(:icon_path, [ "../../etc", "passwd" ])
      assert_includes path.to_s, "app/assets/images/icons/etc/passwd.svg"
      assert_not_includes path.to_s, "../"
    end

    def test_icon_path_with_traversal_in_icon_name
      icon = Anyicon::Icon.new("fontawesome_regular:../../secret")
      path = icon.send(:icon_path, [ "fontawesome_regular", "../../secret" ])
      assert_not_includes path.to_s, "../"
      assert_includes path.to_s, "icons/fontawesome_regular/secret.svg"
    end

    def test_icon_url_sanitizes_icon_name
      icon = Anyicon::Icon.new("fontawesome_regular:../../../etc/passwd")
      url = icon.send(:icon_url, [ "fontawesome_regular", "../../../etc/passwd" ])
      assert_includes url, "etcpasswd.svg"
      assert_not_includes url, "../"
    end

    def test_icon_url_returns_nil_for_unknown_collection_after_sanitization
      icon = Anyicon::Icon.new("../../hack:icon")
      url = icon.send(:icon_url, [ "../../hack", "icon" ])
      assert_nil url
    end
  end

  class XssAttributeFilterTest < ActiveSupport::TestCase
    def test_filters_onclick_attribute
      icon = Anyicon::Icon.new("fontawesome_regular:address-book", onclick: "alert(1)")
      rendered = icon.render
      assert_not_includes rendered, "onclick"
      assert_not_includes rendered, "alert"
    end

    def test_filters_onload_attribute
      icon = Anyicon::Icon.new("fontawesome_regular:address-book", onload: "alert(1)")
      rendered = icon.render
      assert_not_includes rendered, "onload"
    end

    def test_filters_onerror_attribute
      icon = Anyicon::Icon.new("fontawesome_regular:address-book", onerror: "alert(1)")
      rendered = icon.render
      assert_not_includes rendered, "onerror"
    end

    def test_filters_onmouseover_attribute
      icon = Anyicon::Icon.new("fontawesome_regular:address-book", onmouseover: "alert(1)")
      rendered = icon.render
      assert_not_includes rendered, "onmouseover"
    end

    def test_allows_class_attribute
      icon = Anyicon::Icon.new("fontawesome_regular:address-book", class: "my-class")
      rendered = icon.render
      assert_includes rendered, 'class="my-class'
    end

    def test_allows_id_attribute
      icon = Anyicon::Icon.new("fontawesome_regular:address-book", id: "my-id")
      rendered = icon.render
      assert_includes rendered, 'id="my-id"'
    end

    def test_allows_style_attribute
      icon = Anyicon::Icon.new("fontawesome_regular:address-book", style: "color: red")
      rendered = icon.render
      assert_includes rendered, 'style="color: red"'
    end

    def test_allows_width_and_height
      icon = Anyicon::Icon.new("fontawesome_regular:address-book", width: "24", height: "24")
      rendered = icon.render
      assert_includes rendered, 'width="24"'
      assert_includes rendered, 'height="24"'
    end

    def test_allows_fill_and_stroke
      icon = Anyicon::Icon.new("fontawesome_regular:address-book", fill: "red", stroke: "blue")
      rendered = icon.render
      assert_includes rendered, 'fill="red"'
      assert_includes rendered, 'stroke="blue"'
    end

    def test_allows_aria_attributes
      icon = Anyicon::Icon.new("fontawesome_regular:address-book", "aria-label": "Icon", "aria-hidden": "true")
      rendered = icon.render
      assert_includes rendered, 'aria-label="Icon"'
      assert_includes rendered, 'aria-hidden="true"'
    end

    def test_allows_data_attributes
      icon = Anyicon::Icon.new("fontawesome_regular:address-book", "data-controller": "icon", "data-action": "click")
      rendered = icon.render
      assert_includes rendered, 'data-controller="icon"'
      assert_includes rendered, 'data-action="click"'
    end

    def test_filters_mixed_allowed_and_disallowed
      icon = Anyicon::Icon.new("fontawesome_regular:address-book", class: "safe", onclick: "alert(1)", id: "ok", onload: "hack()")
      rendered = icon.render
      assert_includes rendered, 'class="safe'
      assert_includes rendered, 'id="ok"'
      assert_not_includes rendered, "onclick"
      assert_not_includes rendered, "onload"
    end

    def test_filters_href_attribute
      icon = Anyicon::Icon.new("fontawesome_regular:address-book", href: "javascript:alert(1)")
      rendered = icon.render
      assert_not_includes rendered, "href"
      assert_not_includes rendered, "javascript"
    end
  end

  class SsrfProtectionTest < ActiveSupport::TestCase
    def setup
      @common = Anyicon::Common.new
    end

    def test_blocks_http_urls
      assert_raises(Net::HTTPError) do
        @common.fetch("http://github.com/some/path")
      end
    end

    def test_blocks_disallowed_host
      assert_raises(Net::HTTPError) do
        @common.fetch("https://evil.com/some/path")
      end
    end

    def test_blocks_internal_hosts
      assert_raises(Net::HTTPError) do
        @common.fetch("https://localhost/admin")
      end
    end

    def test_blocks_internal_ip
      assert_raises(Net::HTTPError) do
        @common.fetch("https://169.254.169.254/latest/meta-data")
      end
    end

    def test_returns_nil_for_nil_url
      assert_nil @common.fetch(nil)
    end

    def test_raises_on_too_many_redirects
      assert_raises(Net::HTTPError) do
        @common.fetch("https://github.com/some/path", 0)
      end
    end

    def test_allows_github_com
      response = Net::HTTPSuccess.allocate
      Net::HTTP.any_instance.stubs(:request).returns(response)

      result = @common.fetch("https://github.com/some/path")
      assert_equal response, result
    end

    def test_allows_raw_githubusercontent
      response = Net::HTTPSuccess.allocate
      Net::HTTP.any_instance.stubs(:request).returns(response)

      result = @common.fetch("https://raw.githubusercontent.com/user/repo/main/icon.svg")
      assert_equal response, result
    end

    def test_allows_api_github
      response = Net::HTTPSuccess.allocate
      Net::HTTP.any_instance.stubs(:request).returns(response)

      result = @common.fetch("https://api.github.com/repos/user/repo/contents")
      assert_equal response, result
    end

    def test_redirect_to_disallowed_host_is_blocked
      redirect_response = Net::HTTPRedirection.allocate
      redirect_response.stubs(:[]).with("location").returns("https://evil.com/steal-data")
      Net::HTTP.any_instance.stubs(:request).returns(redirect_response)

      assert_raises(Net::HTTPError) do
        @common.fetch("https://github.com/some/path")
      end
    end

    def test_error_message_includes_host
      error = assert_raises(Net::HTTPError) do
        @common.fetch("https://evil.com/path")
      end
      assert_includes error.message, "evil.com"
    end
  end
end
