# frozen_string_literal: true

require_relative "./type"

module Dry
  module Typescript
    module TsTypes
      class Object < Type
        attribute :schema, DryTypes::Hash.optional
        attribute :render_as, DryTypes::String.default("type").enum(*%w[type interface const])

        def typescript_keyword
          render_as
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
