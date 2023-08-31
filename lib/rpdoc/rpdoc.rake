# frozen_string_literal: true

require 'rpdoc'

namespace :rpdoc do
  desc 'configure'
  task :configure, [:path] do |task, args|
    path = args[:path] || 'config/initializers/rpdoc.rb'
    require_relative path if File.exist?(path)
  end

  desc 'merge all collections'
  task :merge_all, [:collection_path] do |task, args|
    collection = Rpdoc::PostmanCollection.new(configuration: configuration)
    Dir.glob("#{args[:collection_path]}/**/collection_*.json").each do |collection_path|
      sub_collection = Rpdoc::PostmanCollection.new(data: JSON.parse(File.read(collection_path)))
      collection.merge!(sub_collection)
    end
    collection.save
  end

  desc 'push collection to the Postman server'
  task :push do
    postman_collection = Rpdoc::PostmanCollection.new
    postman_collection.save
    postman_collection.send(Rpdoc.configuration.rpdoc_auto_push_strategy) if Rpdoc.configuration.rpdoc_auto_push
  end
end
