# frozen_string_literal: true

require 'rails/generators'

module Rpdoc
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __dir__)
      desc 'Creates an initializer file at config/initializers.'

      def copy_initializer_file
        copy_file "initializer.rb", "#{Rails.root}/config/initializers/rpdoc.rb"
      end
    end
  end
end