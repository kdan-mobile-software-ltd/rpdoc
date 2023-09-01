# lib/railtie.rb
require 'rpdoc'
require 'rails'

module Rpdoc
  class Railtie < Rails::Railtie
    railtie_name :rpdoc

    rake_tasks do
      path = File.expand_path(__dir__)
      load "#{path}/rpdoc.rake"
    end
  end
end