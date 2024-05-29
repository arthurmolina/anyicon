# frozen_string_literal: true

namespace :anyicon do
  desc 'Download a specific icon collection'
  task :download_collection, [:collection] => :environment do |_t, args|
    collection = args[:collection]
    if Anyicon.configuration.collections.keys.include?(collection.to_sym)
      Anyicon::Collection.new(collection.to_sym).download_all
    else
      puts "Collection #{collection} not found."
    end
  end

  desc 'Download all icon collections'
  task download_all_collections: :environment do
    puts 'Downloading all icon collections'
    Anyicon.configuration.collections.each_key do |collection|
      puts "Downloading #{collection}..."
      Anyicon::Collection.new(collection).download_all
    end
  end
end
