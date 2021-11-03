# frozen_string_literal: true

require 'json_requester'

module Rpdoc
  class PostmanCollection

    def initialize
      @configuration = Rpdoc.configuration
      @requester = JsonRequester.new(@configuration.postman_host)

      @data = generated_collection_data
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
      
      merged_by(remote_collection_data)
      @requester.http_send(:put, path, remote_collection_data, headers)
    end

    def save
      File.open("#{@configuration.rpdoc_root}/#{@configuration.rpdoc_collection_filename}", 'w+') do |f|
        f.write(JSON.pretty_generate(@data))
      end
    end

    private

    def collection_data
      @collection_data ||= @original_collection.present? ? @original_collection.deeper_merge(collection_from_rspec, merge_hash_arrays: true) : collection_from_rspec
    end

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

    def merged_by(other_collection_data)
      clean_generated_responses_from(other_collection_data[:collection][:item])
      insert_generated_responses_into(other_collection_data[:collection][:item])
    end

    def clean_generated_responses_from(collection_items)
      collection_items.each do |item|
        if item.has_key?(:item)
          clean_generated_responses_from(item[:item])
        elsif item.has_key?(:response)
          item[:response] = item[:response].reject do |response|
            response.dig(:header)&.pluck(:key)&.include?('RSpec-Location')
          end
        end
      end
    end

    def insert_generated_responses_into(collection_items, from_collection_items: nil)
      from_collection_items ||= @data[:collection][:item]

      if collection_items.empty?
        collection_items = from_collection_items.deep_dup
      else
        item_hash = {}
        collection_items.each do |item|
          item_hash[item[:name]] = item
        end

        from_collection_items.each do |from_item|
          from_item_name = from_item[:name]
          if item_hash.has_key?(from_item_name)
            if from_item.has_key?(:item) && item_hash[from_item_name].has_key?(:item)
              insert_generated_responses_into(item_hash[from_item_name][:item], from_collection_items: from_item[:item])
            elsif from_item.has_key?(:response) && item_hash[from_item_name].has_key?(:response)
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
  end
end
