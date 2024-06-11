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
      self.reordering!
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
      remote_collection.merge!(self)
      @requester.http_send(:put, path, remote_collection.data, headers)
    end

    def save(path: nil)
      path ||= "#{@configuration.rpdoc_root}/#{@configuration.rpdoc_collection_filename}"
      File.open(path, 'w+') do |f|
        f.write(JSON.pretty_generate(@data))
      end
    end

    def merge!(other_collection)
      @data[:collection][:info][:name] = other_collection.data[:collection][:info][:name]
      @data[:collection][:info][:description] = other_collection.data[:collection][:info][:description]
      insert_generated_responses_into(@data[:collection][:item], from_collection_items: other_collection.data[:collection][:item].to_a)
      sort_folders_from(@data[:collection][:item])
    end

    def clean_empty_folders!
      clean_empty_folders_from(@data[:collection][:item])
    end

    def clean_generated_responses!
      clean_generated_responses_from(@data[:collection][:item])
    end

    def reordering!
      sort_folders_from(@data[:collection][:item])
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
            @configuration.rspec_response_identifier.present? ? response.dig(:header)&.pluck(:key)&.include?('RSpec-Location') : true
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
              insert_generated_responses_into(item_hash[from_item_name][:item], from_collection_items: from_item[:item].to_a)
            elsif from_item.has_key?(:response) && item_hash[from_item_name].has_key?(:response)
              item_hash[from_item_name][:request] = from_item[:request].deep_dup
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
      collection_items&.reject! do |item|
        next false if item.has_key?(:request)
        next false if @configuration.rpdoc_clean_empty_folders_except.include?(item[:name])
        clean_empty_folders_from(item[:item]) if item[:item].present?
        item[:item].nil? || item[:item].empty?
      end
    end

    def sort_folders_from(collection_items)
      return unless @configuration.rpdoc_folder_ordering.present?
      if @configuration.rpdoc_folder_ordering == :asc
        collection_items&.sort_by! { |item| item[:name] }
      elsif @configuration.rpdoc_folder_ordering == :desc
        collection_items&.sort_by! { |item| item[:name] }.reverse!
      elsif @configuration.rpdoc_folder_ordering.is_a?(Array)
        # sort by array and then sort by asc
        collection_items&.sort_by! { |item| [@configuration.rpdoc_folder_ordering.index(item[:name]) || Float::INFINITY, item[:name]] }
      end
    end
  end
end
