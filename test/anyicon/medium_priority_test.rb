# frozen_string_literal: true

require "test_helper"
require "anyicon/icon"
require "anyicon/rails/icon_helper"
require "anyicon/configuration"
require "anyicon/collections"

# Issue #4: Bug no helper — `icon = icon` é uma atribuição redundante
# O helper deveria passar o argumento diretamente, não reatribuí-lo.
class HelperRedundantAssignmentTest < ActionView::TestCase
  include Anyicon::Rails::IconHelper

  def test_helper_passes_icon_param_correctly_via_keyword
    # Quando chamado com keyword `icon:`, o positional `icon` é nil.
    # A atribuição `icon = icon` no helper sobrescreve o local com nil,
    # mas como o keyword ainda está em props, funciona por acidente.
    rendered = anyicon(icon: "fontawesome_regular:address-book")
    assert_includes rendered, "<svg"
  end

  def test_helper_does_not_leak_icon_into_props
    # O `icon = icon` causa uma atribuição desnecessária.
    # Verificamos que `:icon` não aparece como atributo no SVG.
    rendered = anyicon(icon: "fontawesome_regular:address-book")
    assert_not_includes rendered, "icon="
  end

  def test_helper_positional_arg_works
    rendered = anyicon("fontawesome_regular:address-book")
    assert_includes rendered, "<svg"
  end

  def test_helper_positional_with_props_works
    rendered = anyicon("fontawesome_regular:address-book", class: "w-4 h-4")
    assert_includes rendered, "<svg"
    assert_includes rendered, 'class="w-4 h-4'
  end
end

# Issue #6: html_safe em loop — concatenar html_safe em loop é ineficiente
# e potencialmente inseguro. O resultado deveria ser html_safe.
class HtmlSafeRenderTest < ActiveSupport::TestCase
  def test_render_returns_html_safe_string
    icon = Anyicon::Icon.new("fontawesome_regular:address-book")
    result = icon.render
    assert result.html_safe?, "render should return an html_safe string"
  end

  def test_render_multiple_icons_returns_html_safe
    # Criamos um segundo SVG temporário para testar múltiplos ícones
    second_icon_dir = ::Rails.root.join("app", "assets", "images", "icons", "fontawesome_regular")
    second_icon_path = second_icon_dir.join("star.svg")
    FileUtils.mkdir_p(second_icon_dir)
    File.write(second_icon_path, '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M12 2l3 7h7l-5.5 4 2 7L12 16l-6.5 4 2-7L2 9h7z"/></svg>')

    icon = Anyicon::Icon.new("fontawesome_regular:address-book,fontawesome_regular:star")
    result = icon.render
    assert result.html_safe?, "render with multiple icons should return html_safe"
    assert_includes result, "<svg"
    # Deve conter dois SVGs
    assert_equal 2, result.scan("<svg").count
  ensure
    File.delete(second_icon_path) if second_icon_path && File.exist?(second_icon_path)
  end

  def test_render_empty_icon_returns_html_safe
    icon = Anyicon::Icon.new("nonexistent_collection:fake-icon")
    icon.stubs(:ensure_icon_exists).returns(nil)
    result = icon.render
    assert result.html_safe?, "render with missing icon should still return html_safe"
  end
end

# Issue #8: Nokogiri não declarada como dependência no gemspec
class GemspecDependencyTest < ActiveSupport::TestCase
  def test_nokogiri_is_declared_as_dependency
    gemspec_path = File.expand_path("../../anyicon.gemspec", __dir__)
    gemspec_content = File.read(gemspec_path)

    # Nokogiri é usada em lib/anyicon/icon.rb mas não está no gemspec
    assert_match(/add_dependency.*nokogiri/i, gemspec_content,
      "Nokogiri should be declared as a runtime dependency in the gemspec")
  end
end

# Issue #9: Cobertura de testes — Configuration não tinha testes
class ConfigurationTest < ActiveSupport::TestCase
  def setup
    @config = Anyicon::Configuration.new
  end

  def test_default_collections_are_loaded
    assert_not_empty @config.collections
  end

  def test_default_collections_include_fontawesome
    assert @config.collections.key?(:fontawesome_regular)
    assert @config.collections.key?(:fontawesome_solid)
    assert @config.collections.key?(:fontawesome_brands)
  end

  def test_default_collections_include_heroicons
    assert @config.collections.key?(:heroicons_outline)
    assert @config.collections.key?(:heroicons_solid)
  end

  def test_default_collections_include_tabler
    assert @config.collections.key?(:tabler_icons_filled)
    assert @config.collections.key?(:tabler_icons_outline)
  end

  def test_each_collection_has_required_keys
    @config.collections.each do |name, collection|
      assert collection.key?(:repo), "#{name} missing :repo"
      assert collection.key?(:path), "#{name} missing :path"
      assert collection.key?(:branch), "#{name} missing :branch"
    end
  end

  def test_add_collections_merges_new_collections
    @config.add_collections(
      my_custom: { repo: "user/repo", path: "icons", branch: "main" }
    )
    assert @config.collections.key?(:my_custom)
    assert_equal "user/repo", @config.collections[:my_custom][:repo]
  end

  def test_add_collections_does_not_remove_defaults
    @config.add_collections(
      my_custom: { repo: "user/repo", path: "icons", branch: "main" }
    )
    assert @config.collections.key?(:fontawesome_regular),
      "Adding collections should not remove default collections"
  end

  def test_collections_can_be_replaced_entirely
    @config.collections = { only_this: { repo: "a/b", path: "c", branch: "d" } }
    assert_equal 1, @config.collections.size
    assert @config.collections.key?(:only_this)
  end

  def test_configure_block_yields_configuration
    Anyicon.configure do |config|
      assert_kind_of Anyicon::Configuration, config
    end
  end

  def test_configuration_is_singleton
    config1 = Anyicon.configuration
    config2 = Anyicon.configuration
    assert_same config1, config2
  end
end

# Issue #9: Cobertura de testes — Collection não tinha testes
class CollectionTest < ActiveSupport::TestCase
  def test_collection_url_for_known_collection
    collection = Anyicon::Collection.new(:fontawesome_regular)
    url = collection.send(:collection_url)
    assert_includes url, "api.github.com"
    assert_includes url, "FortAwesome/Font-Awesome"
    assert_includes url, "svgs/regular"
  end

  def test_collection_url_returns_nil_for_unknown
    collection = Anyicon::Collection.new(:nonexistent)
    url = collection.send(:collection_url)
    assert_nil url
  end

  def test_list_returns_empty_array_for_nil_url
    collection = Anyicon::Collection.new(:nonexistent)
    result = collection.list
    assert_kind_of Array, result
    assert_empty result
  end

  def test_download_all_logs_message_when_empty
    collection = Anyicon::Collection.new(:nonexistent)
    collection.stubs(:list).returns([])
    # Should use Rails.logger, not puts — no stdout output expected
    assert_output("") { collection.download_all }
  end

  def test_download_all_logs_via_rails_logger
    collection = Anyicon::Collection.new(:fontawesome_regular)
    collection.stubs(:list).returns([
      { "name" => "test.svg", "download_url" => nil }
    ])
    # Should use Rails.logger, not puts — no stdout output expected
    assert_output("") { collection.download_all }
  end

  def test_icon_path_is_within_assets
    collection = Anyicon::Collection.new(:fontawesome_regular)
    path = collection.send(:icon_path, "address-book.svg")
    assert_includes path.to_s, "app/assets/images/icons/fontawesome_regular/address-book.svg"
  end
end

# Issue #9: Cobertura de testes — Cenários de erro do Icon
class IconErrorScenariosTest < ActiveSupport::TestCase
  def test_render_nonexistent_icon_returns_empty
    icon = Anyicon::Icon.new("fontawesome_regular:this-icon-does-not-exist")
    icon.stubs(:download_icon).returns(nil)
    result = icon.render
    assert_equal "", result
  end

  def test_icon_url_returns_nil_for_unknown_collection
    icon = Anyicon::Icon.new("unknown_collection:some-icon")
    url = icon.send(:icon_url, [ "unknown_collection", "some-icon" ])
    assert_nil url
  end

  def test_icon_url_returns_valid_url_for_known_collection
    icon = Anyicon::Icon.new("fontawesome_regular:address-book")
    url = icon.send(:icon_url, [ "fontawesome_regular", "address-book" ])
    assert_not_nil url
    assert_includes url, "github.com"
    assert_includes url, "FortAwesome/Font-Awesome"
    assert_includes url, "address-book.svg"
  end

  def test_render_with_nil_icon_does_not_crash
    icon = Anyicon::Icon.new(nil)
    icon.stubs(:ensure_icon_exists).returns(nil)
    assert_nothing_raised { icon.render }
  end

  def test_render_with_empty_string_does_not_crash
    icon = Anyicon::Icon.new("")
    icon.stubs(:ensure_icon_exists).returns(nil)
    assert_nothing_raised { icon.render }
  end
end
