# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:suite) do 
    raise StandardError.new('Configuration Invalid') unless Rpdoc.configuration.valid?
    Dir.glob("#{Rpdoc.configuration.rpdoc_root}/**/*.json") do |filename|
      File.delete(filename)
    end
  end

  config.after(:suite) do
    if Rpdoc.configuration.rpdoc_auto_push
      postman_collection = Rpdoc::PostmanCollection.new
      postman_collection.save
      postman_collection.send(Rpdoc.configuration.rpdoc_auto_push_strategy)
    end
  end
end
  
RSpec.shared_context 'rpdoc' do
  after(:each) do |example|
    example.metadata[:rpdoc_skip] ||= false
    if example.exception.nil? && example.metadata[:type] == :request && example.metadata[:rpdoc_skip] == false
      example.metadata[:rpdoc_action_key] ||= controller.action_name
      example.metadata[:rpdoc_action_name] ||= controller.action_name
      example.metadata[:rpdoc_example_key] ||= example.metadata[:description].underscore
      example.metadata[:rpdoc_example_name] ||= example.metadata[:description]
      example.metadata[:rpdoc_example_folders] ||= controller.controller_path.split('/')
      
      postman_response = Rpdoc::PostmanResponse.new(example, request, response)
      postman_response.save
    end
  end
end
