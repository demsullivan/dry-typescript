# frozen_string_literal: true

require_relative './type'

module Dry
  module Typescript
    module Types
      class Primitive < Type
        option :type_name
        option :array, default: ->{ false }

        TYPE_MAP = {
          "NilClass"   => "null",
          "Symbol"     => "string",
          "String"     => "string",
          "Date"       => "string",
          "DateTime"   => "string",
          "Time"       => "string",
          "Class"      => "any",
          "TrueClass"  => "boolean",
          "FalseClass" => "boolean",
          "Float"      => "number",
          "BigDecimal" => "number",
          "Integer"    => "number"
        }

        def typescript_value

          val = type_name.is_a?(String) ? type_name : TYPE_MAP.fetch(type_name.to_s) do
            raise "Unknown primitive type: #{type_name}"
          end

          array ? "#{val}[]" : val
        end
      end
    end
  end
end
