# frozen_string_literal: true

require_relative './type'

module Dry
  module Typescript
    module Types
      class Primitive < Type
        option :type_name

        def typescript_value
          case type_name.to_s
          when "String"
            'string'
          when "Integer"
            'number'
          when "BigDecimal"
            'number'
          when "Date"
            'Date'
          when "DateTime"
            'Date'
          when "TrueClass"
            'boolean'
          when "FalseClass"
            'boolean'
          when "NilClass"
            'null'
          else
            raise "Unknown primitive type: #{type}"
          end
        end
      end
    end
  end
end
