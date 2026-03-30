# frozen_string_literal: true

require "bundler/setup"
require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: :rubocop

path = File.expand_path(__dir__)
Dir.glob("#{path}/lib/rpdoc/**/*.rake").each { |f| import f }
