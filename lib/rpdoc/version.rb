# frozen_string_literal: true

# Root namespace for rpdoc gem components.
module Rpdoc
  version_file = File.expand_path("../../VERSION.md", __dir__)
  VERSION = File.read(version_file, encoding: "UTF-8").strip
end
