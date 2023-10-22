# frozen_string_literal: true

require_relative './type'

module Dry
  module Typescript
    module Types
      class Object < Type
        option :schema, optional: true
        option :interface, default: -> { false }

        def typescript_keyword
          interface ? "interface" : "type"
        end

        def typescript_value
          if schema.nil? || schema.empty?
            "{ [key: any]: any }\n"
          else
            "{\n  #{schema.map { |key, value| "#{key}: #{value.to_typescript}" }.join("\n")}\n}\n"
          end
        end
      end
    end
  end
end
