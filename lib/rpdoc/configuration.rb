# frozen_string_literal: true

module Rpdoc
  class Configuration
    attr_reader \
      :postman_host,
      :postman_collection_path,
      :collection_schema

    attr_accessor \
      :rpdoc_enable,
      :postman_apikey,
      :collection_workspace,
      :collection_uid,
      :collection_name,
      :rspec_root,
      :rspec_server_host,
      :rspec_request_allow_headers,
      :rpdoc_root,
      :rpdoc_request_filename,
      :rpdoc_description_filename,
      :rpdoc_collection_filename,
      :rpdoc_clean_empty_folders,
      :rpdoc_clean_empty_folders_except,
      :rpdoc_auto_push,
      :rpdoc_auto_push_strategy

    def initialize
      @rpdoc_enable = ENV['RPDOC_ENABLE'] != 'false'

      @postman_host = 'https://api.getpostman.com'
      @postman_collection_path = "/collections"
      @postman_apikey = nil

      @collection_workspace = nil
      @collection_uid = nil
      @collection_name = 'Rpdoc'
      @collection_schema = 'https://schema.getpostman.com/json/collection/v2.1.0/collection.json'

      @rspec_root = 'spec'
      @rspec_server_host = '{{server_host}}'
      @rspec_request_allow_headers = ['User-Agent', 'Content-Type', 'Authorization']

      @rpdoc_root = 'rpdoc'
      @rpdoc_request_filename = 'request.json'
      @rpdoc_description_filename = 'description.md'
      @rpdoc_collection_filename = 'collection.json'

      @rpdoc_clean_empty_folders = true
      @rpdoc_clean_empty_folders_except = []

      @rpdoc_auto_push = false
      @rpdoc_auto_push_strategy = :push_and_create # or :push_and_update
    end
  
    def valid?
      return true unless @rpdoc_enable && @rpdoc_auto_push
      return false if @postman_apikey.nil?
      return false if @rpdoc_auto_push_strategy == :push_and_update && @collection_uid.nil?
      true
    end
  end
end
