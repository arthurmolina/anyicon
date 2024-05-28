# Anyicon

[![Gem Version](https://badge.fury.io/rb/anyicon.svg)](https://badge.fury.io/rb/anyicon)

**Anyicon** provides Ruby on Rails view helpers for rendering icons from various collections hosted on GitHub.

<img src="docs/anyicon.png">

## How does it work

Anyicon simplifies the process of integrating and using SVG icons from various collections in your Rails application. Here's a breakdown of how it works:

1. **Configuration:** You can set up the icon collections you want to use in a Rails initializer (`config/initializers/anyicon.rb`) or you can use the already defined collections. Each collection is defined by specifying the GitHub repository, the path within the repository where the icons are located, and the branch to use.

2. **Icon Rendering:** When you call the `anyicon` helper in your views, it uses the `Anyicon::Icon` class to render the SVG content. The helper takes the icon name in the format `collection:icon_name` and optionally additional HTML properties.

3. **Fetching Icons:** If the requested icon is not already cached locally, the gem will fetch the SVG file from the specified GitHub repository. It uses the configuration settings to construct the URL, download the file, and store it in your application's `app/assets/images/icons` directory. **Attention to the license agreement of each collection**

4. **Caching:** Once downloaded, icons are cached locally to avoid repeated network requests. This ensures that your application remains performant and reduces dependency on external network availability.

5. **Helper Methods:** The `anyicon` helper method simplifies the process of including icons in your views by managing the rendering and fetching process transparently. You can also pass additional HTML attributes to customize the rendered SVG element.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'anyicon'
```

And then execute:

```sh
bundle install
```

Or install it yourself as:

```sh
gem install anyicon
```

## Usage

You can just use the anyicon helper in your views:

```erb
<%= anyicon icon: 'fontawesome_regular:address-book' %>
```

## Configuration

You can configure the icon collections in an initializer:

```ruby
# config/initializers/anyicon.rb
Anyicon.configure do |config|
  config.collections = {
    my_custom_collection: { repo: 'user/repo', path: 'path/to/icons', branch: 'main' }
  }
end
```

## Collections Available

| Collection                           | Github List          | Example                          | Quantity | License |
|--------------------------------------|----------------------|----------------------------------|---------|---|
| [Font-Awesome](https://fontawesome.com/) | [fontawesome_regular](https://github.com/FortAwesome/Font-Awesome/tree/6.x/svgs/regular) | fontawesome_regular:address-book | 136 | [License](https://fontawesome.com/license) |
|                                          | [fontawesome_solid](https://github.com/FortAwesome/Font-Awesome/tree/6.x/svgs/solid) | fontawesome_solid:award | 1,392 | |
|                                          | [fontawesome_brands](https://github.com/FortAwesome/Font-Awesome/tree/6.x/svgs/brands) | fontawesome_brands:readme | 490 | |
| [Heroicons](https://heroicons.com/)  | [heroicons_outline](https://github.com/tailwindlabs/heroicons/tree/master/optimized/24/outline)   | heroicons_outline:check           | 296 | [MIT](https://github.com/tailwindlabs/heroicons/blob/master/LICENSE) |
|                                      | [heroicons_solid](https://github.com/tailwindlabs/heroicons/tree/master/optimized/24/solid)   | heroicons_solid:cube           | 296 | |
| [Tabler Icons](https://tabler-icons.io/) | [tabler_icons_filled](https://github.com/tabler/tabler-icons/tree/main/icons/filled) | tabler_icons_filled:alarm | 675 | [MIT](https://github.com/tabler/tabler-icons/blob/master/LICENSE) |
|                                          | [tabler_icons_outline](https://github.com/tabler/tabler-icons/tree/main/icons/outline) | tabler_icons_outline:article | 4,615 | |
| [Mage Icons](https://mageicons.com/) | [mage_icons_fill](https://github.com/Mage-Icons/mage-icons/tree/main/svg/bulk) | mage_icons_fill:Book | 449 |[Apache 2.0](https://github.com/Mage-Icons/mage-icons/blob/main/License.txt) |
|                                      | [mage_icons_stroke](https://github.com/Mage-Icons/mage-icons/tree/main/svg/stroke) | mage_icons_stroke:Archive               | 545 | |
|                                      | [mage_icons_social_bw](https://github.com/Mage-Icons/mage-icons/tree/main/svg/social-bw) | mage_icons_social_bw:Github             | 50 | |
|                                      | [mage_icons_social_color](https://github.com/Mage-Icons/mage-icons/tree/main/svg/social-color) | mage_icons_social_color:Youtube         | 50 | |
| [Line Awesome](https://icons8.com/line-awesome) | [line_awesome](https://github.com/icons8/line-awesome/tree/master/svg) | line_awesome:film | 1,554 | MIT/[Good Boy License](https://icons8.com/good-boy-license/) |
| [@carbon/icons](https://github.com/carbon-design-system/carbon/tree/main/packages/icons) | [carbon](https://github.com/carbon-design-system/carbon/tree/main/packages/icons/src/svg/32) | carbon:arrow--left | 2,212 | [Apache 2.0](https://github.com/carbon-design-system/carbon/blob/main/LICENSE) |
| [IonIcons](https://ionic.io/ionicons) | [ionicons](https://github.com/ionic-team/ionicons/tree/main/src/svg) | ionicons:add-sharp | 1,356 | [MIT](https://github.com/ionic-team/ionicons/blob/main/LICENSE) |
| [Feather Icons](https://feathericons.com/) | [feather_icons](https://github.com/feathericons/feather/tree/main/icons) | feather_icons:airplay | 287 | [MIT](https://github.com/feathericons/feather/blob/master/LICENSE) |

Please, read the license before using any of these collections. This gem does not maintain or keep any of those files in it's repository. However, when you use any of the icons they will be automatically saved in `/app/assets/images/icons/` folder.

Fell free to add your own collection to this list.

## Development

To get started with development:

```
git clone https://github.com/arthurmolina/anyicon.git
cd heroicon
bundle install
bundle exec rake test
```

## Contributing

Anyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/arthurmolina/anyicon/issues)
- Fix bugs and [submit pull requests](https://github.com/arthurmolina/anyicon/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
