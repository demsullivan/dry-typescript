# frozen_string_literal: true

require_relative "typescript/version"
require_relative "typescript/compiler"

module Dry
  module Typescript
    def self.generate(types_module:, filename: nil)
      compiler = Compiler.new(types_module)
      type_definitions = compiler.compile

      if filename
        File.open(filename, "w") do |file|
          type_definitions.each do |type_definition|
            file.write(type_definition)
          end
        end
      end

      type_definitions
    end
  end
end
