# frozen_string_literal: true

require_relative "lib/rpdoc/version"

Gem::Specification.new do |spec|
  spec.name          = "rpdoc"
  spec.version       = Rpdoc::VERSION
  spec.authors       = ["yuntai"]
  spec.email         = ["yuntai.yang@kdanmobile.com"]

  spec.summary       = "RSpec to Postman Documentation Tool"
  spec.description   = "Rpdoc is a simple Postman API documentation tool, which transforms RSpec examples to Postman collection."
  spec.homepage      = "https://github.com/kdan-mobile-software-ltd/rpdoc"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")
  spec.metadata = {
    "source_code_uri" => "https://github.com/kdan-mobile-software-ltd/rpdoc",
    "changelog_uri" => "https://github.com/kdan-mobile-software-ltd/rpdoc/blob/master/CHANGELOG.md"
  }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activesupport", ">= 7.1", "< 9.0"
  spec.add_runtime_dependency "json_requester", "~> 2.0", ">= 2.0.1"

  spec.add_development_dependency "pry", "~> 0.14", ">= 0.14.1"
  spec.add_development_dependency "railties", ">= 7.1", "< 9.0"
  spec.add_development_dependency "rspec", "~> 3.13"
  spec.add_development_dependency "rubocop", "~> 1.78"
end
