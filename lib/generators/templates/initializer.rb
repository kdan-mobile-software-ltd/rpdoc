# frozen_string_literal: true

Rpdoc.configure do |config|

  # (Must) Apikey for your Postman account.
  config.postman_apikey = 'postman_apikey'

  # (Optional) Workspace that your collection will be push to. Default your account's personal workspace. 
  # config.collection_workspace = 'collection_workspace'
  
  # (Optional) Your existing collection uid. Will update it when using :push_and_update push strategy.
  # config.collection_uid = 'collection_uid'
  
  # (Optional) Collection name.
  # config.collection_name = 'Rpdoc'
  
  # (Optional) Your Rails server API host.
  # config.server_host = '{{server_host}}'

  # (Optional) Since Rspec generates many noisy headers, you can filter them.
  # config.rspec_request_allow_headers = ['User-Agent', 'Content-Type', 'Authorization']

  # (Optional) Folder that Rpdoc use for json data generation and save.
  # config.rpdoc_root = 'rpdoc'

  # (Optional) Filename to store RSpec request json data.
  # config.rpdoc_request_filename = 'request.json'

  # (Optional) Filename to store Postman description markdown data.
  # config.rpdoc_description_filename = 'description.md'

  # (Optional) Filename to store RSpec collection json data.
  # config.rpdoc_collection_filename = 'collection.json'

  # (Optional) Auto push collection to Postman server or not.
  # config.rpdoc_auto_push = false

  # (Optional) Auto push strategy, including :push_and_create and :push_and_update
  # config.rpdoc_auto_push_strategy = :push_and_create
end
