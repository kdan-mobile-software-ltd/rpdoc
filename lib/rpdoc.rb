# frozen_string_literal: true

require 'rpdoc/version'
require 'rpdoc/configuration'
require 'rpdoc/postman_response'
require 'rpdoc/postman_collection'
require 'rpdoc/helper' if defined?(RSpec)

module Rpdoc

  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure(&block)
    yield(configuration)
  end

end
