# frozen_string_literal: true

module Rpdoc
  class Configuration
    attr_reader \
      :postman_host,
      :postman_collection_endpoint,
      :collection_schema

    attr_accessor \
      :postman_apikey,
      :collection_workspace,
      :collection_uid,
      :collection_name,
      :server_host,
      :rspec_request_allow_headers,
      :rpdoc_root,
      :rpdoc_request_filename,
      :rpdoc_description_filename,
      :rpdoc_collection_filename,
      :rpdoc_auto_push,
      :rpdoc_auto_push_strategy

    def initialize
      @postman_host = 'https://api.getpostman.com'
      @postman_collection_endpoint = "#{@postman_host}/collections"
      @postman_apikey = nil

      @collection_workspace = nil
      @collection_uid = nil
      @collection_name = 'Rpdoc'
      @collection_schema = 'https://schema.getpostman.com/json/collection/v2.1.0/collection.json'

      @server_host = '{{server_host}}'
      @rspec_request_allow_headers = ['User-Agent', 'Content-Type', 'Authorization']

      @rpdoc_root = 'rpdoc'
      @rpdoc_request_filename = 'request.json'
      @rpdoc_description_filename = 'description.md'
      @rpdoc_collection_filename = 'collection.json'
      @rpdoc_auto_push = false
      @rpdoc_auto_push_strategy = :push_and_create # or :push_and_update
    end
  
    def valid?
      !@postman_apikey.nil?
    end
  end
end
