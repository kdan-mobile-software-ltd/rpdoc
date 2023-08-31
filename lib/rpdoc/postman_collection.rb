# frozen_string_literal: true

require 'json_requester'
require 'active_support'
require 'active_support/core_ext'

module Rpdoc
  class PostmanCollection
    attr_reader :data

    def initialize(configuration: nil, data: nil)
      @configuration = configuration || Rpdoc.configuration
      @requester = JsonRequester.new(@configuration.postman_host)
      @data = data&.deep_symbolize_keys || generated_collection_data

      self.clean_empty_folders!
    end

    def push
      send(@configuration.rpdoc_auto_push_strategy)
    end

    def push_and_create
      path = "#{@configuration.postman_collection_path}?workspace=#{@configuration.collection_workspace}"
      headers = {
        'X-Api-Key': @configuration.postman_apikey
      }
      @requester.http_send(:post, path, @data, headers)
    end

    def push_and_update
      path = "#{@configuration.postman_collection_path}/#{@configuration.collection_uid}"
      headers = {
        'X-Api-Key': @configuration.postman_apikey
      }
      remote_collection_data = @requester.http_send(:get, path, {}, headers)
      remote_collection_data = remote_collection_data['status'] == 200 ? remote_collection_data.deep_symbolize_keys.slice(:collection) : nil
      remote_collection = PostmanCollection.new(data: remote_collection_data)
      remote_collection.clean_generated_responses!
      
      self.merge!(remote_collection)
      @requester.http_send(:put, path, @data, headers)
    end

    def save(path: nil)
      path ||= "#{@configuration.rpdoc_root}/#{@configuration.rpdoc_collection_filename}"
      File.open(path, 'w+') do |f|
        f.write(JSON.pretty_generate(@data))
      end
    end

    def merge!(other_collection)
      insert_generated_responses_into(@data[:collection][:item], from_collection_items: other_collection.data[:collection][:item])
    end

    def clean_empty_folders!
      clean_empty_folders_from(@data[:collection][:item])
    end

    def clean_generated_responses!
      clean_generated_responses_from(@data[:collection][:item])
    end

    private

    def generated_collection_data
      {
        collection: {
          info: {
            name: @configuration.collection_name,
            description: description(@configuration.rpdoc_root),
            schema: @configuration.collection_schema
          },
          item: items(@configuration.rpdoc_root)
        }
      }
    end

    def description(folder)
      File.read("#{folder}/#{@configuration.rpdoc_description_filename}") rescue ""
    end

    def items(folder)
      data = []
      Dir.glob("#{folder}/*") do |filename|
        next unless File.directory?(filename)
        request_file = File.read("#{filename}/#{@configuration.rpdoc_request_filename}") rescue nil
        request_data = JSON.parse(request_file).deep_symbolize_keys if request_file.present?
        if request_data.present?
          Dir.glob("#{filename}/*") do |response_filename|
            next unless response_filename.match?(/.json$/) && response_filename != "#{filename}/#{@configuration.rpdoc_request_filename}"
            response_data = JSON.parse(File.read(response_filename)).deep_symbolize_keys
            request_data[:response] << response_data
          end
          request_data[:request][:description] = description(filename)
          data << request_data
        else
          data << {
            name: filename.split('/').last.camelize,
            description: description(filename),
            item: items(filename)
          }
        end
      end
      data
    end

    def clean_generated_responses_from(collection_items)
      collection_items.each do |item|
        if item.has_key?(:item)
          clean_generated_responses_from(item[:item])
        elsif item.has_key?(:response)
          item[:response].reject! do |response|
            response.dig(:header)&.pluck(:key)&.include?('RSpec-Location')
          end
        end
      end
    end

    def insert_generated_responses_into(collection_items, from_collection_items: [])
      if collection_items.empty?
        from_collection_items.each do |item|
          collection_items << item.deep_dup
        end
      else
        # transform collection_items into hash, using item[:name] as key
        item_hash = {}
        collection_items.each do |item|
          item_hash[item[:name]] = item
        end

        # insert generated responses and replace description into corresponding items based on item[:name]
        from_collection_items.each do |from_item|
          from_item_name = from_item[:name]
          if item_hash.has_key?(from_item_name)
            if from_item.has_key?(:item) && item_hash[from_item_name].has_key?(:item)
              item_hash[from_item_name][:description] = from_item[:description]
              insert_generated_responses_into(item_hash[from_item_name][:item], from_collection_items: from_item[:item])
            elsif from_item.has_key?(:response) && item_hash[from_item_name].has_key?(:response)
              item_hash[from_item_name][:request][:description] = from_item[:request][:description]
              item_hash[from_item_name][:response] += from_item[:response].deep_dup
            else
              collection_items << from_item.deep_dup
            end
          else
            collection_items << from_item.deep_dup
          end
        end
      end
    end

    def clean_empty_folders_from(collection_items)
      return unless @configuration.rpdoc_clean_empty_folders
      collection_items.reject! do |item|
        next false if item.has_key?(:request)
        next false if @configuration.rpdoc_clean_empty_folders_except.include?(item[:name])
        clean_empty_folders_from(item[:item]) if item[:item].present?
        item[:item].nil? || item[:item].empty?
      end
    end
  end
end
