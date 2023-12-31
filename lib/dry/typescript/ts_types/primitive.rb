# frozen_string_literal: true

require_relative "./type"

module Dry
  module Typescript
    module TsTypes
      class Primitive < Type
        attribute :type_name, DryTypes::String | DryTypes::Class

        TYPE_MAP = {
          "NilClass" => "null",
          "Symbol" => "string",
          "String" => "string",
          "Date" => "string",
          "DateTime" => "string",
          "Time" => "string",
          "Class" => "any",
          "TrueClass" => "boolean",
          "FalseClass" => "boolean",
          "Float" => "number",
          "BigDecimal" => "number",
          "Integer" => "number",
          "Array"   => "Array<any>"
        }.freeze

        def with_transformed_types
          new_type_name = yield type_name
          self.class.new(name: name, type_name: new_type_name)
        end

        def typescript_value
          if type_name.is_a?(String)
            type_name
          else
            TYPE_MAP.fetch(type_name.to_s) do
              raise "Unknown primitive type: #{type_name}"
            end
          end
        end
      end
    end
  end
end
