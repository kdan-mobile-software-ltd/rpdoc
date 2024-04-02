# frozen_string_literal: true
require 'rspec/rails' if defined?(RSpec::Rails)

RSpec.configure do |config|
  config.before(:suite) do
    root = Rpdoc.configuration.rpdoc_root
    if Rpdoc.configuration.rpdoc_enable
      raise StandardError.new('Configuration Invalid') unless Rpdoc.configuration.valid?
      FileUtils.mkdir_p(root) unless File.exist?(root)
      Dir.glob("#{root}/**/*.json") do |filename|
        File.delete(filename)
      end
    end
  end

  config.after(:suite) do
    if Rpdoc.configuration.rpdoc_enable
      postman_collection = Rpdoc::PostmanCollection.new
      postman_collection.save
      postman_collection.send(Rpdoc.configuration.rpdoc_auto_push_strategy) if Rpdoc.configuration.rpdoc_auto_push
    end
  end
end
  
RSpec.shared_context 'rpdoc' do
  after(:each) do |example|
    example.metadata[:rpdoc_skip] ||= false

    example_usable = true
    example_usable &&= example.metadata[:rpdoc_skip] == false
    example_usable &&= File.expand_path(example.metadata[:file_path]).start_with?(File.expand_path(Rpdoc.configuration.rspec_root))
    example_usable &&= example.exception.nil? && example.metadata[:type] == :request

    if Rpdoc.configuration.rpdoc_enable && example_usable
      example.metadata[:rpdoc_action_key] ||= controller.action_name
      example.metadata[:rpdoc_action_name] ||= controller.action_name
      example.metadata[:rpdoc_example_key] ||= example.metadata[:description].underscore
      example.metadata[:rpdoc_example_name] ||= example.metadata[:description]
      example.metadata[:rpdoc_example_folders] ||= controller.class.controller_path.split('/')
      
      postman_response = Rpdoc::PostmanResponse.new(example, request, response)
      postman_response.save
    end
  end
end
