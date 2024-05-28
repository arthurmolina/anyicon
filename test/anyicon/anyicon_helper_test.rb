# frozen_string_literal: true

require 'test_helper'
require 'anyicon/rails/icon_helper'

class AnyiconHelperTest < ActionView::TestCase
  include Anyicon::Rails::IconHelper

  def setup
    @icon_name = 'fontawesome_regular:address-book'
  end

  def test_anyicon_helper
    rendered_icon = anyicon(icon: @icon_name)
    assert_includes rendered_icon, '<svg'
  end

  def test_anyicon_helper_with_additional_props
    rendered_icon = anyicon(icon: @icon_name, class: 'custom-class', id: 'custom-id')
    assert_includes rendered_icon, '<svg'
    assert_includes rendered_icon, 'class="custom-class'
    assert_includes rendered_icon, 'id="custom-id"'
  end
end
