# frozen_string_literal: true

module Anyicon
  module Rails
    module IconHelper
      # Renders an icon using the Anyicon gem.
      #
      # @param icon [String] the name of the icon in the format 'collection:icon_name'
      # @param props [Hash] additional properties to apply to the SVG element
      # @return [String] the rendered SVG icon
      def anyicon(icon:, **props)
        Anyicon::Icon.render(icon:, **props)
      end
    end
  end
end
