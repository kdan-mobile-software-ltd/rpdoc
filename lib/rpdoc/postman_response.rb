# frozen_string_literal: true

module Rpdoc
  class PostmanResponse
    attr_reader :data

    def initialize(rspec_example, rspec_request, rspec_response)
      @rspec_example = rspec_example
      @rspec_request = rspec_request
      @rspec_response = rspec_response
      @configuration = Rpdoc.configuration

      @data = response_data
    end

    def save
      root_path ||= @configuration.rpdoc_root
      folder_path = "#{root_path}/#{@rspec_example.metadata[:rpdoc_example_folders].join('/')}/#{@rspec_example.metadata[:rpdoc_action_key]}"
      FileUtils.mkdir_p(folder_path) unless File.exists?(folder_path)

      request_file_path = "#{folder_path}/#{@configuration.rpdoc_request_filename}"
      File.open(request_file_path, 'w+') { |f| f.write(JSON.pretty_generate(request_data)) } unless File.exists?(request_file_path)

      response_file_path = "#{folder_path}/#{@rspec_example.metadata[:rpdoc_example_key]}.json"
      File.open(response_file_path, 'w+') { |f| f.write(JSON.pretty_generate(response_data)) }
    end

    private

    def request_data
      {
        name: @rspec_example.metadata[:rpdoc_action_name],
        request: original_request_data,
        response: []
      }
    end

    def response_data
      headers = @rspec_response.header.map { |key, value| {key: key, value: value} }
      headers << rspec_location_header
      {
        name: @rspec_example.metadata[:rpdoc_example_name],
        originalRequest: original_request_data,
        status: @rspec_response.status.to_s,
        code: @rspec_response.code.to_i,
        _postman_previewlanguage: "json",
        header: headers,
        body: JSON.pretty_generate(JSON.parse(@rspec_response.body))
      }
    end

    def rspec_location_header
      {
        key: 'RSpec-Location',
        value: @rspec_example.metadata[:location]
      }
    end

    def original_request_data
      return @original_request_data if @original_request_data.present?
      filter_headers = @configuration.rspec_request_allow_headers.map do |header|
        next unless @rspec_request.headers[header].present?
        {
          key: header,
          value: @rspec_request.headers[header]
        }
      end.compact
      @original_request_data = {
        method: @rspec_request.method,
        header: filter_headers,
        url: {
          raw: "#{@configuration.server_host}#{@rspec_request.path}",
          host: [@configuration.server_host],
          path: @rspec_request.path.split('/'),
          variable: [],
        },
        body: nil
      }
      @original_request_data[:body] = {
        mode: 'raw',
        raw: JSON.pretty_generate(JSON.parse(@rspec_request.headers['RAW_POST_DATA'])),
        options: {
          raw: {
            language: "json"
          }
        }
      } if @rspec_request.headers['RAW_POST_DATA'].present?
      @original_request_data
    end  
  end
end