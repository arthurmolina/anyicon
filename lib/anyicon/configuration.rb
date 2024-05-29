# frozen_string_literal: true

# The Configuration class is responsible for holding the configuration settings
# for the Anyicon gem. It provides a default set of icon collections that can be
# customized by the user.
module Anyicon
  # Example usage:
  #
  #   Anyicon.configure do |config|
  #     config.add_collections(
  #       custom_collection: {
  #         repo: 'user/repo',
  #         path: 'path/to/icons',
  #         branch: 'main'
  #       }
  #     )
  #   end
  #
  # The class also allows setting additional configuration options such as
  # `default_class`, which can be used to apply a default CSS class to every icon.
  class Configuration
    # A hash containing the default icon collections. Each collection specifies the
    # repository, path, and branch where the icons can be found.
    DEFAULT_COLLECTIONS = {
      fontawesome_regular: { repo: 'FortAwesome/Font-Awesome', path: 'svgs/regular', branch: '6.x' },
      fontawesome_solid: { repo: 'FortAwesome/Font-Awesome', path: 'svgs/solid', branch: '6.x' },
      fontawesome_brands: { repo: 'FortAwesome/Font-Awesome', path: 'svgs/brands', branch: '6.x' },
      heroicons_outline: { repo: 'tailwindlabs/heroicons', path: 'optimized/24/outline', branch: 'master' },
      heroicons_solid: { repo: 'tailwindlabs/heroicons', path: 'optimized/24/solid', branch: 'master' },
      tabler_icons_filled: { repo: 'tabler/tabler-icons', path: 'icons/filled', branch: 'main' },
      tabler_icons_outline: { repo: 'tabler/tabler-icons', path: 'icons/outline', branch: 'main' },
      mage_icons_fill: { repo: 'Mage-Icons/mage-icons', path: 'svg/bulk', branch: 'main' },
      mage_icons_stroke: { repo: 'Mage-Icons/mage-icons', path: 'svg/stroke', branch: 'main' },
      mage_icons_social_bw: { repo: 'Mage-Icons/mage-icons', path: 'svg/social-bw', branch: 'main' },
      mage_icons_social_color: { repo: 'Mage-Icons/mage-icons', path: 'svg/social-color', branch: 'main' },
      line_awesome: { repo: 'icons8/line-awesome', path: 'svg', branch: 'master' },
      carbon: { repo: 'carbon-design-system/carbon', path: 'packages/icons/src/svg/32', branch: 'main' },
      ionicons: { repo: 'ionic-team/ionicons', path: 'src/svg', branch: 'main' },
      feather_icons: { repo: 'feathericons/feather', path: 'icons', branch: 'main' }
    }.freeze

    # @return [Hash] the configured icon collections
    attr_accessor :collections

    # Initializes a new Configuration instance with default settings.
    def initialize
      @collections = DEFAULT_COLLECTIONS.dup
    end

    def add_collections(new_collections)
      @collections.merge!(new_collections)
    end
  end

  # Provides access to the configuration instance.
  #
  # @return [Anyicon::Configuration] the configuration instance
  def self.configuration
    @configuration ||= Configuration.new
  end

  # Yields the configuration instance to a block for customization.
  #
  # @yieldparam [Anyicon::Configuration] config the configuration instance
  def self.configure
    yield configuration
  end
end
