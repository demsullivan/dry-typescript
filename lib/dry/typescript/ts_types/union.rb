# frozen_string_literal: true

require_relative "./type"

module Dry
  module Typescript
    module TsTypes
      class Union < Type
        attribute :types, DryTypes::Array.of(TsTypes::Type)

        def typescript_value
          return "boolean" if is_boolean?

          values = cleaned_types.map(&:to_typescript)
          values << "null" if is_nullable?
          values.join(" | ")
        end

        def cleaned_types
          types.reject { |type| type.is_a?(Primitive) && type.type_name.to_s == "NilClass" }
        end

        def is_nullable?
          types.count == 2 && \
            types.any? { |type| type.is_a?(Primitive) && type.type_name.to_s == "NilClass" }
        end

        def is_boolean?
          types.count == 2 && \
            types.all? { |type| type.is_a?(Primitive) } && \
            types.map(&:type_name).map(&:to_s).sort == %w[FalseClass TrueClass]
        end
      end
    end
  end
end
