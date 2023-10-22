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
            file.write(type_definition.to_s)
          end
        end
      end

      type_definitions.map(&:to_s)
    end

    def self.generate_type_definitions(types_module)
      types_module.constants.each do |constant_name|
        constant = types_module.const_get(constant_name)

        case constant
        when Module
          generate_type_definitions(types_module: constant)
        when Dry::Types::Constrained
          generate_type_definition_from_constrained(type: constant)
        when Dry::Types::Sum
          generate_type_definition_from_sum(type: constant)
        when Dry::Types::Enum
          generate_type_definition_from_enum(type: constant)
        when Class
          generate_type_definition_from_class(type: constant)
        else
          raise Error.new("Unsupported type: #{constant}")
        end
      end
    end

    def self.generate_type_definition_from_constrained(type:)
      # don't generate type definitions for primitive types

      type_definition = <<~TYPESCRIPT
        export type #{type.name} = #{type.primitive.name}
      TYPESCRIPT
    end
  end
end
