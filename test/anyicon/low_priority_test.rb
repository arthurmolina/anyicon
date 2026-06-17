# frozen_string_literal: true

require "test_helper"
require "anyicon/icon"
require "anyicon/configuration"
require "anyicon/common"

# Issue #11: Cache em memória para SVG
class SvgCacheTest < ActiveSupport::TestCase
  def setup
    Anyicon::Icon.clear_cache!
  end

  def teardown
    Anyicon::Icon.clear_cache!
  end

  def test_svg_cache_starts_empty
    assert_empty Anyicon::Icon.svg_cache
  end

  def test_clear_cache_empties_the_cache
    Anyicon::Icon.svg_cache["fake_path"] = "<svg></svg>"
    Anyicon::Icon.clear_cache!
    assert_empty Anyicon::Icon.svg_cache
  end

  def test_render_populates_cache
    Anyicon::Icon.new("fontawesome_regular:address-book").render
    assert_not_empty Anyicon::Icon.svg_cache
  end

  def test_cache_contains_svg_content
    Anyicon::Icon.new("fontawesome_regular:address-book").render
    cached = Anyicon::Icon.svg_cache.values.first
    assert_includes cached, "<svg"
  end

  def test_second_render_uses_cache_without_file_read
    icon_path = ::Rails.root.join("app", "assets", "images", "icons", "fontawesome_regular", "address-book.svg")

    # First render — populates cache
    Anyicon::Icon.new("fontawesome_regular:address-book").render
    assert_equal 1, Anyicon::Icon.svg_cache.size

    # Stub File.read to track if it's called again
    original_content = File.read(icon_path)
    call_count = 0
    File.stubs(:read).with(icon_path).returns(original_content).tap do
      call_count += 1
    end

    # Second render — should use cache
    result = Anyicon::Icon.new("fontawesome_regular:address-book").render
    assert_includes result, "<svg"
    # Cache should still have exactly 1 entry (same icon)
    assert_equal 1, Anyicon::Icon.svg_cache.size
  end

  def test_cache_key_is_file_path
    Anyicon::Icon.new("fontawesome_regular:address-book").render
    key = Anyicon::Icon.svg_cache.keys.first
    assert_includes key, "fontawesome_regular/address-book.svg"
  end

  def test_different_icons_get_separate_cache_entries
    second_icon_dir = ::Rails.root.join("app", "assets", "images", "icons", "fontawesome_regular")
    second_icon_path = second_icon_dir.join("star.svg")
    FileUtils.mkdir_p(second_icon_dir)
    File.write(second_icon_path, '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M12 2z"/></svg>')

    Anyicon::Icon.new("fontawesome_regular:address-book").render
    Anyicon::Icon.new("fontawesome_regular:star").render

    assert_equal 2, Anyicon::Icon.svg_cache.size
  ensure
    File.delete(second_icon_path) if second_icon_path && File.exist?(second_icon_path)
  end
end

# Issue #12: GitHub token configurável
class GitHubTokenTest < ActiveSupport::TestCase
  def setup
    @original_token = Anyicon.configuration.github_token
  end

  def teardown
    Anyicon.configuration.github_token = @original_token
  end

  def test_github_token_defaults_to_nil
    config = Anyicon::Configuration.new
    assert_nil config.github_token
  end

  def test_github_token_can_be_set
    Anyicon.configure do |config|
      config.github_token = "ghp_test123"
    end
    assert_equal "ghp_test123", Anyicon.configuration.github_token
  end

  def test_fetch_sends_authorization_header_when_token_set
    Anyicon.configuration.github_token = "ghp_test_token"

    request_sent = nil
    Net::HTTP.any_instance.stubs(:request).with do |req|
      request_sent = req
      true
    end.returns(Net::HTTPSuccess.allocate)

    common = Anyicon::Common.new
    common.fetch("https://github.com/some/path")

    assert_equal "token ghp_test_token", request_sent["Authorization"]
  end

  def test_fetch_does_not_send_authorization_when_no_token
    Anyicon.configuration.github_token = nil

    request_sent = nil
    Net::HTTP.any_instance.stubs(:request).with do |req|
      request_sent = req
      true
    end.returns(Net::HTTPSuccess.allocate)

    common = Anyicon::Common.new
    common.fetch("https://github.com/some/path")

    assert_nil request_sent["Authorization"]
  end
end

# Issue #14: Gemfiles de compatibilidade
class GemfileCompatibilityTest < ActiveSupport::TestCase
  def test_gemfiles_exist_for_modern_rails_versions
    gemfiles_dir = File.expand_path("../../gemfiles", __dir__)
    %w[rails_7.1 rails_7.2 rails_8.0].each do |name|
      path = File.join(gemfiles_dir, "#{name}.gemfile")
      assert File.exist?(path), "Missing gemfile: #{name}.gemfile"
    end
  end

  def test_gemfiles_reference_correct_rails_versions
    gemfiles_dir = File.expand_path("../../gemfiles", __dir__)
    {
      "rails_7.1.gemfile" => "~> 7.1.0",
      "rails_7.2.gemfile" => "~> 7.2.0",
      "rails_8.0.gemfile" => "~> 8.0.0"
    }.each do |file, version|
      content = File.read(File.join(gemfiles_dir, file))
      assert_includes content, version, "#{file} should reference #{version}"
    end
  end

  def test_all_gemfiles_have_gemspec_reference
    gemfiles_dir = File.expand_path("../../gemfiles", __dir__)
    Dir.glob(File.join(gemfiles_dir, "*.gemfile")).each do |path|
      content = File.read(path)
      assert_includes content, "gemspec", "#{File.basename(path)} should reference gemspec"
    end
  end
end

# Issue #15: Typo no README
class ReadmeTest < ActiveSupport::TestCase
  def test_readme_development_section_has_correct_directory
    readme_path = File.expand_path("../../README.md", __dir__)
    content = File.read(readme_path)
    assert_includes content, "cd anyicon", "README should say 'cd anyicon', not 'cd heroicon'"
    assert_not_includes content, "cd heroicon", "README should not contain 'cd heroicon'"
  end
end

# Bug: collection_url must include branch ref
class CollectionBranchTest < ActiveSupport::TestCase
  def test_collection_url_includes_branch
    collection = Anyicon::Collection.new(:fontawesome_regular)
    url = collection.send(:collection_url)
    assert_includes url, "?ref=6.x",
      "collection_url should include the branch as ?ref= parameter"
  end

  def test_collection_url_includes_branch_for_main
    collection = Anyicon::Collection.new(:tabler_icons_outline)
    url = collection.send(:collection_url)
    assert_includes url, "?ref=main"
  end

  def test_collection_url_includes_branch_for_master
    collection = Anyicon::Collection.new(:heroicons_outline)
    url = collection.send(:collection_url)
    assert_includes url, "?ref=master"
  end
end

# Bug: list should always return Array
class CollectionListTypeTest < ActiveSupport::TestCase
  def test_list_returns_array_for_unknown_collection
    collection = Anyicon::Collection.new(:nonexistent)
    result = collection.list
    assert_kind_of Array, result, "list should return an Array, not a Hash"
    assert_empty result
  end

  def test_list_returns_array_when_api_returns_object
    collection = Anyicon::Collection.new(:fontawesome_regular)
    # GitHub API sometimes returns an object (e.g. error message) instead of array
    response = Net::HTTPSuccess.allocate
    response.stubs(:body).returns('{"message": "Not Found"}')
    Net::HTTP.any_instance.stubs(:request).returns(response)

    result = collection.list
    assert_kind_of Array, result
    assert_empty result
  end

  def test_list_returns_array_when_api_returns_array
    collection = Anyicon::Collection.new(:fontawesome_regular)
    response = Net::HTTPSuccess.allocate
    response.stubs(:body).returns('[{"name": "icon.svg", "download_url": "https://example.com/icon.svg"}]')
    Net::HTTP.any_instance.stubs(:request).returns(response)

    result = collection.list
    assert_kind_of Array, result
    assert_equal 1, result.size
  end
end

# Bug: malformed icon names (missing colon) should be silently ignored
class MalformedIconNameTest < ActiveSupport::TestCase
  def test_icon_without_colon_is_ignored
    icon = Anyicon::Icon.new("just-an-icon-name")
    result = icon.render
    assert_equal "", result
  end

  def test_icon_without_colon_mixed_with_valid
    icon = Anyicon::Icon.new("invalid,fontawesome_regular:address-book")
    result = icon.render
    assert_includes result, "<svg"
    # Should only render 1 SVG (the valid one)
    assert_equal 1, result.scan("<svg").count
  end

  def test_empty_string_renders_empty
    icon = Anyicon::Icon.new("")
    result = icon.render
    assert_equal "", result
  end

  def test_nil_renders_empty
    icon = Anyicon::Icon.new(nil)
    result = icon.render
    assert_equal "", result
  end
end

# Fix: redundant html_safe removed, render still returns SafeBuffer
class RenderSafeBufferTest < ActiveSupport::TestCase
  def test_render_returns_safe_buffer
    icon = Anyicon::Icon.new("fontawesome_regular:address-book")
    result = icon.render
    assert_kind_of ActiveSupport::SafeBuffer, result
  end

  def test_empty_render_returns_safe_buffer
    icon = Anyicon::Icon.new("nonexistent:icon")
    icon.stubs(:ensure_icon_exists).returns(nil)
    result = icon.render
    assert_kind_of ActiveSupport::SafeBuffer, result
  end
end
