# Rpdoc

`Rpdoc` is a simple `Postman` API documentation tool, which transforms RSpec examples to Postman collection (with json files in Postman data format stored locally).

### Benefits
- Save time for generating Postman examples manually.
- Improve maintainability of your API documentation (easy to create/update and put it into version control with CI/CD).


## Installation

Add `rpdoc` to your application's `Gemfile`:

```ruby
gem 'rpdoc'
```

And then install the gem:

```bash
$ bundle install
```

## Configuration

`Rpdoc` should be configured manually if you want to automatically push your collection to the Postman server.

You can also run the following command to generate the configuration file for your **Rails** application.

```bash
$ rails g rpdoc:install
```

Rpdoc can be configured by the following options.

```ruby
Rpdoc.configure do |config|
    
  # (Optional) You can disable rpdoc generation process manually.
  config.rpdoc_enable = true

  # (Optional) Apikey for your Postman account, used if want to push collection to the Postman server.
  config.postman_apikey = 'postman_apikey'

  # (Optional) Workspace that your collection will be pushed to. Default your account's personal workspace. 
  config.collection_workspace = 'collection_workspace'
  
  # (Optional) Your existing collection uid. Will update it when using :push_and_update push strategy.
  config.collection_uid = 'collection_uid'
  
  # (Optional) Collection name.
  config.collection_name = 'Rpdoc'
  
  # (Optional) Your Rails server API host.
  config.rspec_server_host = '{{server_host}}'

  # (Optional) Since Rspec generates many noisy headers, you can filter them.
  config.rspec_request_allow_headers = ['User-Agent', 'Content-Type', 'Authorization']

  # (Optional) Folder that Rpdoc use for json data generation and save.
  config.rpdoc_root = 'rpdoc'

  # (Optional) Filename to store RSpec request json data.
  config.rpdoc_request_filename = 'request.json'

  # (Optional) Filename to store Postman description markdown data.
  config.rpdoc_description_filename = 'description.md'

  # (Optional) Filename to store RSpec collection json data.
  config.rpdoc_collection_filename = 'collection.json'

  # (Optional) Auto push collection to Postman server or not.
  config.rpdoc_auto_push = false

  # (Optional) Clean empty folders. You can specify folder names which will be ignored when cleaning.
  config.rpdoc_clean_empty_folders = true
  config.rpdoc_clean_empty_folders_except = []

  # (Optional) Auto push strategy, including :push_and_create and :push_and_update
  config.rpdoc_auto_push_strategy = :push_and_create
end
```

## Usage

`Rpdoc` only supports RSpec examples with [request](https://relishapp.com/rspec/rspec-rails/docs/request-specs/request-spec) type.

1. Include [shared_context](https://relishapp.com/rspec/rspec-core/docs/example-groups/shared-context) in your spec to make `Rpdoc` identify which examples to transform.
    ```ruby
    RSpec.describe 'POST /api/v1/books', type: :request do
      include_context 'rpdoc'
      ...
    end
   ```
2. Customiz your example [metdata](https://relishapp.com/rspec/rspec-core/docs/metadata/user-defined-metadata) to generate collection data in your preferenced format.
    ```ruby
    it 'should return 200' do |example|
        # Request identifier.
        # Default is `controller.action_name` 
        example.metadata[:rpdoc_action_key] = 'create'
        
        # Request name shown in Postman collection.
        # Default is `controller.action_name` 
        example.metadata[:rpdoc_action_name] = 'Create a book.'
        
        # Example identifier.
        # Default is `controller.action_name` 
        example.metadata[:rpdoc_example_key] = "create_200"
        
        # Example name shown in Postman colleciotn. 
        # Default is `example.metadata[:description]`
        example.metadata[:rpdoc_example_name] = "Create a book success."
        
        # Example location shown in Postman collection.
        # Default is `controller.controller_path.split('/')`
        example.metadata[:rpdoc_example_folders] = ['v1', 'books']
        
        # Skip this example if you have already included shared context in the spec.
        # Default is `false`.
        example.metadata[:rpdoc_skip] = false
    end
    ```
3. Run your specs, generate data in Postman format, and push your collection to the Postman server.
   ```bash
   $ rspec
   ```

   If you want to disable `Rpdoc` generation process manually, you can either set `rpdoc_enable = false` in configuration or just pass environment variable to rspec.
   ```bash
   $ RPDOC_ENABLE=false rspec
   ```

4. You can write description for your Postman collection by creating markdown files (named `description.md`) and putting each of them in corresponding location under `rpdoc` folder.

## Notice

If you try to mock the `File.open` method, generating collection data will fail because creating `request.json` use the `File.open` method.

Solution:

You can add code in RSpec.

```ruby
after(:each) do
 allow(File).to receive(:open).and_call_original
end
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
