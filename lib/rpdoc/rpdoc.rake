namespace :rpdoc do
  desc 'push collection to the Postman server'
  task :push => :environment do
    postman_collection = Rpdoc::PostmanCollection.new
    postman_collection.save
    postman_collection.send(Rpdoc.configuration.rpdoc_auto_push_strategy) if Rpdoc.configuration.rpdoc_auto_push
  end
end
