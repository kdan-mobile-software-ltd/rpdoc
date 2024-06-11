# frozen_string_literal: true

require 'cgi'

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
      FileUtils.mkdir_p(folder_path) unless File.exist?(folder_path)

      request_file_path = "#{folder_path}/#{@configuration.rpdoc_request_filename}"
      File.open(request_file_path, 'w+') { |f| f.write(JSON.pretty_generate(request_data)) } unless File.exist?(request_file_path)

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
      header = @rspec_response.header.slice(*@configuration.rspec_response_allow_headers) if @configuration.rspec_response_allow_headers.present?
      headers = header.map { |key, value| { key: key, value: value } }
      headers << rspec_response_identifier_header if @configuration.rspec_response_identifier.present?
      data = {
        name: @rspec_example.metadata[:rpdoc_example_name],
        originalRequest: original_request_data,
        status: @rspec_response.status.to_s,
        code: @rspec_response.code.to_i,
        header: headers,
      }
      if @rspec_response.headers['Content-Type'].include?('application/json')
        data[:_postman_previewlanguage] = 'json'
        data[:body] = JSON.pretty_generate(JSON.parse(@rspec_response.body)) rescue nil
      else
        body = @rspec_response.body
        data[:_postman_previewlanguage] = 'text'
        data[:body] = body.encoding == Encoding::BINARY ? (body.force_encoding(Encoding::ISO_8859_1).encode(Encoding::UTF_8) rescue body) : body
      end
      data
    end

    def rspec_response_identifier_header
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
      query_string = @rspec_request.query_string.split('&').map do |string|
        key, value = string.split('=')
        next if key.nil? || value.nil?
        {
          key: key,
          value: CGI.unescape(value),
          text: 'text'
        }
      end.compact

      original_path = @rspec_request.original_fullpath.split('?').first # use original_fullpath instead of path to avoid request being redirected
      {
        method: @rspec_request.method,
        header: filter_headers,
        url: {
          raw: "#{@configuration.rspec_server_host}#{original_path}",
          host: [@configuration.rspec_server_host],
          path: original_path.split('/'),
          query: query_string
        },
        body: original_request_data_body
      }
    end

    def original_request_data_body
      if @rspec_request.headers['RAW_POST_DATA'].present?
        json_body = JSON.pretty_generate(JSON.parse(@rspec_request.headers['RAW_POST_DATA'])) rescue nil
        {
          mode: 'raw',
          raw: json_body || @rspec_request.headers['RAW_POST_DATA'],
          options: {
            raw: {
              language: json_body.present? ? 'json' : 'text'
            }
          }
        }
      elsif @rspec_request.form_data?
        {
          mode: 'formdata',
          formdata: form_data_object_to_array(@rspec_request.request_parameters)
        }
      else
        nil
      end
    end

    def form_data_object_to_array(form_data, prefix: nil)
      array = []
      form_data.each do |key, value|
        key = "#{prefix}[#{key}]" if prefix.present?
        if value.is_a?(Hash)
          array += form_data_object_to_array(value, prefix: key)
        elsif value.is_a?(Array)
          value.each do |item|
            array += form_data_object_to_array(item, prefix: "#{key}[]")
          end
        elsif value.is_a?(ActionDispatch::Http::UploadedFile)
          array << {
            key: key,
            src: value.original_filename,
            type: 'file'
          }
        else
          array << {
            key: key,
            value: value,
            type: 'text'
          }
        end
      end
      array
    end
  end
end
