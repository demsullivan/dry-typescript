# frozen_string_literal: true

require_relative "lib/dry/typescript/version"

Gem::Specification.new do |spec|
  spec.name          = "dry-typescript"
  spec.version       = Dry::Typescript::VERSION
  spec.authors       = ["Dave Sullivan"]
  spec.email         = ["dave@davesullivan.ca"]

  spec.summary       = "A simple gem to generate TypeScript type definitions from dry-types and dry-structs"
  spec.homepage      = "https://github.com/demsullivan/dry-typescript"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/demsullivan/dry-typescript"
  spec.metadata["changelog_uri"] = "https://github.com/demsullivan/dry-typescript/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "dry-initializer"
  spec.add_dependency "dry-struct"
  spec.add_dependency "dry-types"

  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-mocks", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 0.80"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
