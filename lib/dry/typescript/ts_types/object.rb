# frozen_string_literal: true

require_relative "./type"

module Dry
  module Typescript
    module TsTypes
      class Object < Type
        attribute :schema, DryTypes::Hash.optional
        attribute :render_as, DryTypes::String.default("type").enum(*%w[type interface const])

        def with_transformed_types
          new_schema = schema.map do |key, type|
            [key, yield(type)]
          end.to_h

          self.class.new(name: name, schema: new_schema, render_as: render_as)
        end

        def typescript_keyword
          render_as
        end

        def typescript_value
          if schema.nil? || schema.empty?
            "{ [key: any]: any }"
          else
            "{\n#{schema.map { |key, value| "  #{key}: #{value.to_typescript}" }.join("\n")}\n}"
          end
        end
      end
    end
  end
end
