# frozen_string_literal: true

require_relative "./type"

module Dry
  module Typescript
    module TsTypes
      class Union < Type
        attribute :types, DryTypes::Array.of(TsTypes::Type)

        def with_transformed_types
          new_types = self.types.map {|type| yield type }
          self.class.new(name: name, types: new_types)
        end

        def typescript_value
          return "boolean" if boolean?

          values = cleaned_types.map(&:to_typescript)
          values << "null" if nullable?
          values.join(" | ")
        end

        def cleaned_types
          types.reject { |type| type.is_a?(Primitive) && type.type_name.to_s == "NilClass" }
        end

        def nullable?
          types.count == 2 && \
            types.any? { |type| type.is_a?(Primitive) && type.type_name.to_s == "NilClass" }
        end

        def boolean?
          # Dry::Types::Bool is actually a sum of Dry::Types::True and Dry::Types::False
          types.count == 2 && \
            types.all? { |type| type.is_a?(Primitive) } && \
            types.map(&:type_name).map(&:to_s).sort == %w[FalseClass TrueClass]
        end
      end
    end
  end
end
