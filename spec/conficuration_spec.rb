# frozen_string_literal: true

require 'rpdoc'

describe Rpdoc::Configuration do
  it 'should be configurable' do

    Rpdoc.configure do |config|
      config.postman_apikey = 'postman_apikey'
      config.collection_workspace = 'collection_workspace'
      config.collection_uid = 'collection_uid'
      config.collection_name = 'collection_name'
      config.rspec_server_host = '{{server_host}}'
      config.rspec_request_allow_headers = ['Content-Type']
      config.rpdoc_root = 'rpdoc_root'
      config.rpdoc_request_filename = 'request_filename.json'
      config.rpdoc_description_filename = 'description_filename.md'
      config.rpdoc_collection_filename = 'collection_filename.json'
      config.rpdoc_auto_push = true
      config.rpdoc_auto_push_strategy = :push_and_update
    end
    
    expect(Rpdoc.configuration.postman_apikey).to eq('postman_apikey')
    expect(Rpdoc.configuration.collection_workspace).to eq('collection_workspace')
    expect(Rpdoc.configuration.collection_uid).to eq('collection_uid')
    expect(Rpdoc.configuration.collection_name).to eq('collection_name')
    expect(Rpdoc.configuration.rspec_server_host).to eq('{{server_host}}')
    expect(Rpdoc.configuration.rspec_request_allow_headers).to eq(['Content-Type'])
    expect(Rpdoc.configuration.rpdoc_root).to eq('rpdoc_root')
    expect(Rpdoc.configuration.rpdoc_request_filename).to eq('request_filename.json')
    expect(Rpdoc.configuration.rpdoc_description_filename).to eq('description_filename.md')
    expect(Rpdoc.configuration.rpdoc_collection_filename).to eq('collection_filename.json')
    expect(Rpdoc.configuration.rpdoc_auto_push).to eq(true)
    expect(Rpdoc.configuration.rpdoc_auto_push_strategy).to eq(:push_and_update)
  end
end
